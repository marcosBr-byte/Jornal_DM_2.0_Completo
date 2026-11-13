require "test_helper"

class EditorialFlowTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = User.create!(email: "admin@example.test", password: "EditorialSeguro123!", admin: true)
    @reader = User.create!(email: "reader@example.test", password: "EditorialSeguro123!")
    @draft = @admin.articles.create!(title: "Rascunho privado", body: "Texto interno", author: "Redação", category: "Educação")
    @published = @admin.articles.create!(title: "Notícia pública", body: "Conteúdo público", author: "Redação", category: "Educação", status: :published)
  end

  test "public pages render and drafts are inaccessible" do
    [ root_path, articles_path, escola_path, agenda_path, new_user_session_path, article_path(@published) ].each do |path|
      get path
      assert_response :success
      assert_select "main#main-content", count: 1
    end
    get articles_path
    assert_select "h3", text: @published.title
    assert_select "h3", text: @draft.title, count: 0
    get article_path(@draft)
    assert_response :not_found
  end

  test "public navigation identifies the current page" do
    [ root_path, articles_path, escola_path, agenda_path ].each do |path|
      get path
      assert_select "header nav a[aria-current=page]", count: 1 do |links|
        assert_equal path, links.first["href"]
      end
    end
  end

  test "admin requires authentication and administrator role" do
    get admin_root_path
    assert_redirected_to new_user_session_path
    sign_in @reader
    get admin_articles_path
    assert_response :forbidden
    assert_no_difference "Article.count" do
      post admin_articles_path, params: { article: { title: "Ataque" } }
    end
    assert_response :forbidden
  end

  test "dashboard includes original editorial workspace and administration sidebar" do
    sign_in @admin
    get admin_root_path
    assert_response :success
    assert_select "aside[aria-label='Menu administrativo']", count: 1
    assert_select "main#main-content", count: 1
    assert_select "#editorPanel form[action=?]", admin_articles_path, count: 1
    assert_select "#editorPanel trix-editor[input=article_body]", count: 1
    assert_select "#managePanel a[href=?]", edit_admin_article_path(@draft), text: "Editar"
    assert_select "button[data-action='theme#toggle']", count: 1
    assert_select "footer", count: 0
  end

  test "administrator creates previews edits publishes and deletes" do
    sign_in @admin
    [ admin_root_path, admin_articles_path, new_admin_article_path, edit_admin_article_path(@draft) ].each do |path|
      get path
      assert_response :success
    end
    params = { title: "Nova matéria", body: "<script>alert(1)</script>", author: "Redação", category: "Cultura" }
    assert_difference "Article.count", 1 do
      post admin_articles_path, params: { article: params, intent: "draft" }
    end
    article = Article.order(:id).last
    assert article.draft?
    assert_nil article.published_at
    assert_no_difference "Article.count" do
      post preview_admin_articles_path, params: { article: params }
    end
    assert_response :success
    assert_select "script", text: "alert(1)", count: 0
    patch admin_article_path(article), params: { article: params.merge(title: "Título revisado", lock_version: article.lock_version), intent: "publish" }
    assert_redirected_to admin_articles_path
    assert article.reload.published?
    assert_not_nil article.published_at
    get article_path(article)
    assert_response :success
    assert_select "h1", text: "Título revisado"
    delete admin_article_path(article)
    assert_redirected_to admin_articles_path
    assert_not Article.exists?(article.id)
  end

  test "rich text is preserved across preview publication and editing" do
    sign_in @admin
    fields = { title: "Reportagem formatada", author: "Redação", category: "Cultura", body_format: "html",
      body: '<h2>Seção</h2><div><strong>Trecho importante</strong> e <em>contexto</em>.</div><ol><li>Primeiro item</li></ol><a href="https://example.com">Fonte</a><script>alert(1)</script>' }
    post preview_admin_articles_path, params: { article: fields }
    assert_response :success
    assert_select "h2", text: "Seção"
    assert_select "strong", text: "Trecho importante"
    assert_select "script", text: "alert(1)", count: 0
    post admin_articles_path, params: { article: fields, intent: "publish" }
    assert_redirected_to admin_articles_path
    article = Article.order(:id).last
    assert article.body_format_html?
    get article_path(article)
    assert_response :success
    assert_select "strong", text: "Trecho importante"
    assert_select "ol li", text: "Primeiro item"
    assert_select "a[href='https://example.com']", text: "Fonte"
    assert_select "script", text: "alert(1)", count: 0
    get edit_admin_article_path(article)
    assert_response :success
    assert_select "trix-editor[input=article_body]", count: 1
    assert_select "input[name='article[body_format]'][value=html]", count: 1
    assert_select "input[name='article[body]']" do |inputs|
      assert_includes inputs.first["value"], "<strong>Trecho importante</strong>"
    end
    patch admin_article_path(article), params: { article: fields.merge(body: "<div><em>Texto revisado</em></div>", lock_version: article.lock_version), intent: "draft" }
    assert article.reload.draft?
    assert_includes article.body, "<em>Texto revisado</em>"
  end

  test "legacy body is escaped and paragraphs are retained in the editor" do
    sign_in @admin
    @draft.update!(body: "Primeiro parágrafo\n\nSegundo com 2 < 5.")
    get edit_admin_article_path(@draft)
    assert_response :success
    assert_select "input[name='article[body]']" do |inputs|
      assert_includes inputs.first["value"], "<p>Primeiro parágrafo</p>"
      assert_includes inputs.first["value"], "&lt; 5"
    end
  end

  test "preview accepts an edited article without persisting it" do
    sign_in @admin
    post preview_admin_articles_path, params: { article: { title: "Prévia editada", body: "Texto", author: "Redação", category: "Cultura", lock_version: @draft.lock_version } }
    assert_response :success
    assert_equal "Rascunho privado", @draft.reload.title
  end

  test "recovery form renders" do
    get new_user_password_path
    assert_response :success
  end

  test "filters and invalid submissions" do
    get articles_path, params: { q: "pública", category: "Educação" }
    assert_response :success
    assert_select "h3", text: @published.title
    get articles_path, params: { q: "inexistente" }
    assert_select "h3", text: "Nenhuma notícia encontrada."
    sign_in @admin
    assert_no_difference "Article.count" do
      post admin_articles_path, params: { article: { title: "", body: "", category: "Inexistente" } }
    end
    assert_response :unprocessable_entity
  end

  test "session uses real Argon2 authentication and logout" do
    assert @admin.encrypted_password.start_with?("$argon2")
    post user_session_path, params: { user: { email: @admin.email, password: "senha-incorreta" } }
    assert_response :unprocessable_entity
    post user_session_path, params: { user: { email: @admin.email, password: "EditorialSeguro123!" } }
    assert_response :redirect
    get admin_root_path
    assert_response :success
    delete destroy_user_session_path
    get admin_root_path
    assert_redirected_to new_user_session_path
  end

  test "optimistic locking prevents overwriting concurrent edits" do
    sign_in @admin
    old_version = @draft.lock_version
    @draft.update!(title: "Revisado por colega")
    patch admin_article_path(@draft), params: { article: { title: "Versão antiga", lock_version: old_version }, intent: "draft" }
    assert_redirected_to admin_articles_path
    assert_equal "Revisado por colega", @draft.reload.title
  end
end
