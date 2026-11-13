class ApplicationController < ActionController::Base
  AUTH_RATE_LIMIT_STORE = Rails.env.test? ? ActiveSupport::Cache::MemoryStore.new : Rails.cache

  layout -> { devise_controller? ? "authentication" : "application" }
  def after_sign_in_path_for(resource)
    resource.admin? ? admin_root_path : root_path
  end

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
end
