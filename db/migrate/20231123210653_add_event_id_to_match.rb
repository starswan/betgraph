class AddEventIdToMatch < ActiveRecord::Migration[6.1]
  def change
    change_table :matches, bulk: true do |t|
      t.integer :betfair_event_id
      t.index [:betfair_event_id, :deleted_at], unique: true
    end
  end
end
