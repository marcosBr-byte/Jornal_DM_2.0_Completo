class CoversController < ApplicationController
  def show
    # Never cache a draft or keep a published image after it is unpublished.
    response.headers["Cache-Control"] = "private, no-store, max-age=0"
    response.headers["X-Content-Type-Options"] = "nosniff"
    scope = current_user&.admin? ? Article.all : Article.published
    article = scope.find(params[:id])
    cover = article.cover
    return head :not_found unless cover.attached?
    return head :not_found unless Article::COVER_CONTENT_TYPES.include?(cover.content_type)

    send_data cover.download,
      type: cover.content_type,
      disposition: "inline",
      filename: cover.filename.to_s
  rescue ActiveStorage::FileNotFoundError
    head :not_found
  end
end
