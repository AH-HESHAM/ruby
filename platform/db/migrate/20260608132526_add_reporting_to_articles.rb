class AddReportingToArticles < ActiveRecord::Migration[8.1]
  def change
    add_column :articles, :reports_count, :integer, default: 0
    add_column :articles, :archived, :boolean, default: false
  end
end
