class HasSecurePassword < ActiveRecord::Migration[6.1]
  def change
    rename_column :logins, :password, :password_digest
  end
end
