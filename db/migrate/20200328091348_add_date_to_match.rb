# frozen_string_literal: true

#
# $Id$
#
class AddDateToMatch < ActiveRecord::Migration[5.1]
  BATCH_SIZE = 5000

  def up
    change_table :matches do |t|
      t.date :date, null: true
    end
    index = 0
    count = Match.count
    start = Time.zone.now

    Match.find_in_batches(batch_size: BATCH_SIZE).each do |b|
      percentage = sprintf("%.2f", (100.0 * index / count))
      speed = (Time.zone.now - start) / (index + 1.0)
      finish = Time.zone.now + (count - index) * speed
      say_with_time("#{Time.zone.now} changing #{index}/#{count} #{percentage}% est. finish #{finish}") do
        Match.transaction do
          b.each do |m|
            m.update(date: m.kickofftime.to_date)
          end
        end
        index += BATCH_SIZE
      end
    end
    Match.where(date: nil).destroy_all
    change_column_null :matches, :date, false
  end

  def down
    remove_column :matches, :date
  end
end
