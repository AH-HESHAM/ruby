class DeleteArticleJob < ApplicationJob
  queue_as :default

  def perform(article_id)
    article = Article.find_by(id: article_id)
    if article && article.reports_count >= 6
      article.destroy
    end
  end
end