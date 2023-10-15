class DeleteLoginsTable < ActiveRecord::Migration[6.1]
  def change
    drop_table :logins do |t|
      t.string "name"
      t.binary "username"
      t.binary "password_digest"
    end
  end
end
