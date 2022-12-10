# frozen_string_literal: true

#
# $Id$
#
class TieBasketToBasketRule < ActiveRecord::Migration[5.1]
  BATCH_SIZE = 5000

  def up
    change_table :baskets do |t|
      t.references :basket_rule
    end

    index, count = 0, Basket.count
    start = Time.now

    Basket.includes(match: { division: { sport: :basket_rules } }).find_in_batches(batch_size: BATCH_SIZE) do |batch|
      percentage = "%.2f" % (100.0 * index / count)
      speed = (Time.now - start) / (index + 1.0)
      finish = Time.now + (count - index) * speed
      say_with_time("#{Time.now} changing Basket #{index}/#{count} #{percentage}% est. finish #{finish}") do
        Basket.transaction do
          batch.each do |basket|
            if basket.basket_items_count < 2
              basket.destroy
            else
              rule = basket.match.division.sport.basket_rules.detect { |br| br.name == basket.name }
              basket.update(basket_rule: rule)
            end
          end
        end
      end
      index += BATCH_SIZE
    end

    change_column_null :baskets, :basket_rule_id, false
    remove_column :baskets, :name
    change_column :basket_rules, :id, :bigint, unique: true, null: false, auto_increment: true
    add_foreign_key :baskets, :basket_rules
  end

  def down
    remove_foreign_key :baskets, :basket_rules

    change_table :baskets do |t|
      t.string :name
    end

    index, count = 0, Basket.count
    start = Time.now

    Basket.includes(:basket_rule).find_in_batches(batch_size: BATCH_SIZE) do |batch|
      percentage = "%.2f" % (100.0 * index / count)
      speed = (Time.now - start) / (index + 1.0)
      finish = Time.now + (count - index) * speed
      say_with_time("#{Time.now} rolling back Basket #{index}/#{count} #{percentage}% est. finish #{finish}") do
        Basket.transaction do
          batch.each do |basket|
            basket.update(name: basket.basket_rule.name)
          end
        end
      end
      index += BATCH_SIZE
    end

    remove_column :baskets, :basket_rule_id
  end
end
