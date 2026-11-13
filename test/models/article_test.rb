require "test_helper"
class ArticleTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(email: "editor@example.test", password: "SenhaEditorial123!", admin: true)
  end
  test "validates editorial fields" do
    article = @user.articles.new
    assert_not article.valid?
    article.assign_attributes(title: "A" * 121, body: "Texto", author: "Redação", category: "Outro")
    assert_not article.valid?
  end
  test "rejects unsafe and oversized cover files" do
    article = @user.articles.new(title: "Capa", body: "Texto", author: "Redação", category: "Cultura")
    article.cover.attach(io: StringIO.new("<svg/>"), filename: "capa.svg", content_type: "image/svg+xml")
    assert_not article.valid?
    article.cover.blob.content_type = "image/png"
    article.cover.blob.byte_size = 2.megabytes
    assert_not article.valid?
  end
  test "rich content retains formatting and removes unsafe markup" do
    article = @user.articles.new(title: "Texto formatado", author: "Redação", category: "Cultura", body_format: :html,
      body: '<h2>Título</h2><div><strong>Negrito</strong> e <em>itálico</em></div><ul><li>Item</li></ul><a href="https://example.com">Link</a><script>alert(1)</script><img src=x onerror="alert(2)"><a href="javascript:alert(3)">Inválido</a>')
    assert article.save, article.errors.full_messages.join(", ")
    assert_includes article.body, "<strong>Negrito</strong>"
    assert_includes article.body, "<ul><li>Item</li></ul>"
    assert_includes article.body, 'href="https://example.com"'
    assert_no_match(/<script|<img|onerror|javascript:/i, article.body)
    assert_includes article.body_text, "Negrito"
    assert_no_match(/<strong>|<h2>|<ul>/, article.body_text)
  end

  test "rich content must include visible text" do
    [ "<div><br></div>", "<div>&nbsp;</div>", "<div>\u200b</div>" ].each do |body|
      article = @user.articles.new(title: "Vazio", author: "Redação", category: "Cultura", body_format: :html, body: body)
      assert_not article.valid?
      assert article.errors[:body].any?
    end
  end

  test "legacy text stays unchanged" do
    body = "Primeiro parágrafo\n\nSegundo parágrafo com 2 < 5."
    article = @user.articles.create!(title: "Texto antigo", author: "Redação", category: "Cultura", body: body)
    assert article.body_format_plain?
    assert_equal body, article.reload.body
    assert_equal body, article.body_text
  end
end
