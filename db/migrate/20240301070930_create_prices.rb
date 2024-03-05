class CreatePrices < ActiveRecord::Migration[6.0]
  BATCH_SIZE = 100

  class MarketPrice < ApplicationRecord
    belongs_to :market_price_time, counter_cache: true
  end

  def change
    rename_column :bet_markets, :market_prices_count, :prices_count
    rename_column :market_runners, :market_prices_count, :prices_count
    rename_column :market_price_times, :market_prices_count, :prices_count
    rename_column :matches, :market_prices_count, :prices_count

    hypertable_options = {
      time_column: "created_at",
      # chunk_time_interval: '8 hours',
      compress_segmentby: "market_runner_id",
      # delay compression because data cannot be deleted after this date
      compression_interval: "7 days",
    }
    create_table(:prices, id: false, hypertable: hypertable_options) do |t|
      t.bigint :market_runner_id, null: false
      t.bigint :market_price_time_id, null: false
      t.decimal :back_price, precision: 7, scale: 3
      t.decimal :back_amount, precision: 9, scale: 2
      t.decimal :lay_price, precision: 7, scale: 3
      t.decimal :lay_amount, precision: 9, scale: 2
      t.decimal :last_traded_price, precision: 7, scale: 3
      t.integer :depth, default: 0, null: false
      t.datetime :created_at, precision: 6, null: false
    end

    convert_market_prices_to_prices

    drop_table :market_prices do
      # rubocop:disable Rails/CreateTableWithTimestamps
      create_table :market_prices, force: :cascade do |t|
        t.bigint :market_runner_id
        t.decimal :back1price, precision: 7, scale: 3
        t.decimal :lay1price, precision: 7, scale: 3
        t.decimal :back2price, precision: 7, scale: 3
        t.decimal :lay2price, precision: 7, scale: 3
        t.decimal :back3price, precision: 7, scale: 3
        t.decimal :lay3price, precision: 7, scale: 3
        t.decimal :back1amount, precision: 9, scale: 2
        t.decimal :lay1amount, precision: 9, scale: 2
        t.decimal :back2amount, precision: 9, scale: 2
        t.decimal :lay2amount, precision: 9, scale: 2
        t.decimal :back3amount, precision: 9, scale: 2
        t.decimal :lay3amount, precision: 9, scale: 2
        t.decimal :last_traded_price, precision: 7, scale: 3
        t.bigint :market_price_time_id, null: false
        t.string :status, limit: 20, default: "ACTIVE", null: false
        t.index %w[market_price_time_id]
        t.index %w[market_runner_id]
      end
      # rubocop:enable Rails/CreateTableWithTimestamps
    end
  end

private

  def convert_market_prices_to_prices
    count = MarketPrice.count
    index = 0
    MarketPrice.includes(:market_price_time).find_in_batches(batch_size: BATCH_SIZE) do |mp_batch|
      percent = ((index * 100.0 / count) * 100).to_i / 100.0
      say_with_time "MarketPrice #{index}/#{count} to Price #{percent}%" do
        batch = mp_batch.map do |mp|
          [
            [mp.back1price, mp.back1amount, mp.lay1price, mp.lay1amount, mp.last_traded_price, 1],
            [mp.back2price, mp.back2amount, mp.lay2price, mp.lay2amount, nil, 2],
            [mp.back3price, mp.back3amount, mp.lay3price, mp.lay3amount, nil, 3],
          ].reject { |z| z[0].nil? && z[2].nil? && z[4].nil? }.map do |back_price, back_amount, lay_price, lay_amount, last_traded_price, depth|
            { back_price: back_price,
              back_amount: back_amount,
              lay_price: lay_price,
              lay_amount: lay_amount,
              last_traded_price: last_traded_price,
              depth: depth,
              market_runner_id: mp.market_runner_id,
              market_price_time_id: mp.market_price_time_id,
              created_at: mp.market_price_time.time }
          end
        end
        Price.insert_all batch.flatten.compact
        index += BATCH_SIZE
      end
    end
  end
end
