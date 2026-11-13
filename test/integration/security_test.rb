require "test_helper"
require "base64"

class SecurityTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = User.create!(email: "security-admin@example.test", password: "AuditSecurePassword123!", admin: true)
    @reader = User.create!(email: "security-reader@example.test", password: "AuditSecurePassword123!")
    @article = @admin.articles.create!(title: "Capa protegida", body: "Texto privado", author: "Redação", category: "Avisos")
    ApplicationController::AUTH_RATE_LIMIT_STORE.clear
  end

  teardown do
    @blob&.purge
    ApplicationController::AUTH_RATE_LIMIT_STORE.clear
  end

  test "anonymous direct uploads are disabled and cannot create blobs" do
    assert_no_difference "ActiveStorage::Blob.count" do
      post "/rails/active_storage/direct_uploads", params: { blob: { filename: "invalid.txt", content_type: "text/plain", byte_size: 1, checksum: "invalid" } }, as: :json
    end
    assert_response :not_found
  end

  test "draft covers require an administrator and are never cached" do
    attach_cover
    get cover_article_path(@article)
    assert_response :not_found
    sign_in @reader
    get cover_article_path(@article)
    assert_response :not_found
    sign_out @reader
    sign_in @admin
    get cover_article_path(@article)
    assert_response :success
    assert_equal "image/png", response.media_type
    assert_equal @image, response.body.b
    assert_includes response.headers["Cache-Control"], "no-store"
    assert_equal "nosniff", response.headers["X-Content-Type-Options"]
  end

  test "public covers are served and access is revoked on unpublishing" do
    attach_cover
    @article.update!(status: :published)
    get cover_article_path(@article)
    assert_response :success
    assert_includes response.headers["Cache-Control"], "no-store"
    @article.update!(status: :draft)
    get cover_article_path(@article)
    assert_response :not_found
  end

  test "legacy signed blob proxy and disk routes cannot bypass authorization" do
    attach_cover
    [
      "/rails/active_storage/blobs/redirect/#{@blob.signed_id}/cover.png",
      "/rails/active_storage/blobs/proxy/#{@blob.signed_id}/cover.png",
      "/rails/active_storage/disk/invalid-token/cover.png"
    ].each do |path|
      get path
      assert_response :not_found
    end
  end

  test "missing cover returns not found" do
    @article.update!(status: :published)
    get cover_article_path(@article)
    assert_response :not_found
  end

  test "content security policy protects scripts while allowing the editor" do
    get root_path
    assert_response :success
    policy = response.headers.fetch("Content-Security-Policy")
    assert_includes policy, "object-src 'none'"
    assert_includes policy, "frame-ancestors 'none'"
    script_policy = policy.split(";").find { |part| part.strip.start_with?("script-src ") }
    assert_includes script_policy, "'self'"
    assert_match(/'nonce-[^']+'/, script_policy)
    assert_not_includes script_policy, "'unsafe-inline'"
    assert_select "script[type=importmap][nonce]", count: 1
  end

  test "login rate limit prevents repeated attempts" do
    10.times do
      post user_session_path, params: { user: { email: "unknown@example.test", password: "WrongPassword123!" } }
      assert_response :unprocessable_entity
    end
    post user_session_path, params: { user: { email: "unknown@example.test", password: "WrongPassword123!" } }
    assert_response :too_many_requests
  end

  test "recovery rate limit prevents repeated requests" do
    5.times do
      post user_password_path, params: { user: { email: "unknown@example.test" } }
      assert_response :redirect
    end
    post user_password_path, params: { user: { email: "unknown@example.test" } }
    assert_response :too_many_requests
  end

  test "csrf is enforced for editorial requests" do
    previous = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
    sign_in @admin
    assert_no_difference "Article.count" do
      post admin_articles_path, params: { article: { title: "Sem token", body: "Texto", category: "Avisos", author: "Auditoria" } }
    end
    assert_response :unprocessable_entity
  ensure
    ActionController::Base.allow_forgery_protection = previous
  end

  private

  def attach_cover
    @image = Base64.decode64("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+a8F0AAAAASUVORK5CYII=").b
    @article.cover.attach(io: StringIO.new(@image), filename: "cover.png", content_type: "image/png")
    @blob = @article.cover.blob
  end
end
