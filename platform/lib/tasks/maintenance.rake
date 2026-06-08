namespace :maintenance do
  desc "Finds articles with 6 or more reports and enqueues them for removal"
  task remove_highly_reported_articles: :environment do
    # 1. Grab all articles meeting the criteria
    flagged_articles = Article.where("reports_count >= ?", 6)
    
    if flagged_articles.any?
      puts "Found #{flagged_articles.count} articles with 6+ reports. Enqueueing for deletion..."
      
      # 2. Iterate and pass each ID to the background job
      flagged_articles.find_each do |article|
        DeleteArticleJob.perform_later(article.id)
        puts "Enqueued DeleteArticleJob for Article ID: #{article.id}"
      end
      
      puts "All jobs safely enqueued."
    else
      puts "No articles found with 6 or more reports."
    end
  end
end