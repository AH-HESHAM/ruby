class Article < ApplicationRecord
  belongs_to :user
  has_one_attached :image
  after_commit :check_report_status, on: :update

  private

  def check_report_status
    if saved_change_to_reports_count? && reports_count >= 3
      ArchiveArticleJob.perform_later(self.id)
    end
  end
end