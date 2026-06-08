class ArchiveArticleJob < ApplicationJob
  queue_as :default

  def perform(article_id)
    article = Article.find_by(id: article_id)
    if article && article.reports_count >= 3
      article.update(archived: true, public: false)
    end
  end
end