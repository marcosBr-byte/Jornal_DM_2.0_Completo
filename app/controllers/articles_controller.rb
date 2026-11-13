class ArticlesController < ApplicationController
  def index
    @articles = Article.published.with_attached_cover.editorial_order
    @articles = @articles.where(category: params[:category]) if Article::CATEGORIES.include?(params[:category])
    if params[:q].present?
      query = "%#{Article.sanitize_sql_like(params[:q].to_s.first(200))}%"
      @articles = @articles.where("title ILIKE :q OR summary ILIKE :q OR body ILIKE :q OR author ILIKE :q", q: query)
    end
    @page = [ params[:page].to_i, 1 ].max
    @has_next = @articles.offset(@page * 12).exists?
    @articles = @articles.limit(12).offset((@page - 1) * 12)
  end
  def show
    @article = Article.published.with_attached_cover.find(params[:id])
    @related = Article.published.where(category: @article.category).where.not(id: @article.id).editorial_order.limit(3)
  end
end
