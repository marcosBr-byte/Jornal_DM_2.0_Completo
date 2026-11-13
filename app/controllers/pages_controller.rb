class PagesController < ApplicationController
  def home
    @headline = Article.published.editorial_order.first
    @articles = Article.published.editorial_order.limit(6).with_attached_cover
  end
  def school; end
  def agenda
    @articles = Article.published.where(category: [ "Eventos", "Avisos" ]).editorial_order.limit(20).with_attached_cover
  end
end
