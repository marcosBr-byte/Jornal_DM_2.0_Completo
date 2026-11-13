class CreateArticles < ActiveRecord::Migration[8.1]
  def change
    create_table :articles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false, limit: 120
      t.string :summary, limit: 220
      t.string :author, null: false
      t.string :category, null: false
      t.text :body, null: false
      t.integer :status, null: false, default: 0
      t.boolean :featured, null: false, default: false
      t.datetime :published_at
      t.integer :lock_version, null: false, default: 0
      t.timestamps
    end
    add_index :articles, [ :status, :featured, :published_at ]
    add_check_constraint :articles, "status IN (0, 1)", name: "articles_valid_status"
  end
end
