module Admin
  class DashboardController < BaseController
    def index
      @published_count = Article.published.count
      @featured_count = Article.published.where(featured: true).count
      @category_count = Article.published.distinct.count(:category)
      @draft_count = Article.draft.count
      @article = current_user.articles.new(author: "Redação Jornal DM")
      @articles = Article.with_attached_cover.order(updated_at: :desc).limit(20)
    end
  end
end
