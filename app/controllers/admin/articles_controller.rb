module Admin
  class ArticlesController < BaseController
    before_action :set_article, only: [ :edit, :update, :destroy, :publish ]
    rescue_from ActiveRecord::StaleObjectError do
      redirect_to admin_articles_path, alert: "A notícia foi alterada por outra pessoa. Abra novamente antes de salvar."
    end
    def index
      @published_count = Article.published.count
      @draft_count = Article.draft.count
      @page = [ params[:page].to_i, 1 ].max
      @articles = Article.with_attached_cover.order(updated_at: :desc).limit(20).offset((@page - 1) * 20)
    end
    def new
      @article = current_user.articles.new(author: "Redação Jornal DM")
    end
    def create
      @article = current_user.articles.new(article_params)
      persist(:new)
    end
    def edit; end
    def update
      @article.assign_attributes(article_params)
      persist(:edit)
    end
    def destroy
      @article.destroy!
      redirect_to admin_articles_path, notice: "Publicação excluída.", status: :see_other
    end
    def publish
      @article.update!(status: :published)
      redirect_to admin_articles_path, notice: "Notícia publicada.", status: :see_other
    end
    def preview
      @article = current_user.articles.new(article_params.except(:cover))
      @article.valid?
      render :preview
    end
    private
    def set_article
      @article = Article.find(params[:id])
    end
    def article_params
      params.require(:article).permit(:title, :summary, :body, :body_format, :author, :category, :featured, :cover, :lock_version)
    end
    def persist(template)
      @article.status = params[:intent] == "publish" ? :published : :draft
      if @article.save
        redirect_to admin_articles_path, notice: "Publicação salva.", status: :see_other
      else
        render template, status: :unprocessable_entity
      end
    end
  end
end
