class AddBodyFormatToArticles < ActiveRecord::Migration[8.1]
  def change
    add_column :articles, :body_format, :integer, null: false, default: 0
    add_check_constraint :articles, "body_format IN (0, 1)", name: "articles_valid_body_format"
  end
end
