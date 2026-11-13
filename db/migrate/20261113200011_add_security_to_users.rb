class AddSecurityToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :admin, :boolean, null: false, default: false
    add_column :users, :failed_attempts, :integer, null: false, default: 0
    add_column :users, :locked_at, :datetime
    add_column :users, :provider, :string
    add_column :users, :uid, :string
    add_index :users, [ :provider, :uid ], unique: true
  end
end
