class CreateArticles < ActiveRecord::Migration[8.1]
  def change
    create_table :articles do |t|
      t.string :title
      t.text :body
      t.boolean :public, default: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
