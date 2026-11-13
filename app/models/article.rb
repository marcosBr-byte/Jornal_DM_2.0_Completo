class Article < ApplicationRecord
  CATEGORIES = [ "Educação", "Eventos", "Esportes", "Cultura", "Avisos" ].freeze
  BODY_TAGS = %w[div p br h2 h3 h4 strong b em i s del u ul ol li blockquote pre code a].freeze
  BODY_ATTRIBUTES = %w[href].freeze
  belongs_to :user
  has_one_attached :cover
  enum :status, { draft: 0, published: 1 }, default: :draft
  enum :body_format, { plain: 0, html: 1 }, default: :plain, prefix: true, validate: true
  before_validation :sanitize_rich_body
  validates :title, :body, :author, presence: true
  validate :visible_body
  validates :title, length: { maximum: 120 }
  validates :summary, length: { maximum: 220 }
  validates :category, inclusion: { in: CATEGORIES }
  validate :acceptable_cover
  before_save :stamp_publication
  scope :editorial_order, -> { order(featured: :desc, published_at: :desc, id: :desc) }
  def body_text
    return body.to_s unless body_format_html?
    CGI.unescapeHTML(Loofah.fragment(body.to_s).to_text).strip
  end

  def sanitized_body
    ActionController::Base.helpers.sanitize(body.to_s, tags: BODY_TAGS, attributes: BODY_ATTRIBUTES)
  end

  private

  def sanitize_rich_body
    self.body = sanitized_body if body_format_html? && (body_changed? || body_format_changed?)
  end

  def visible_body
    errors.add(:body, "deve conter texto") if body_format_html? && body_text.gsub(/[[:space:]\u00a0\u200b]/, "").empty?
  end

  def stamp_publication
    self.published_at ||= Time.current if published?
  end
  def acceptable_cover
    return unless cover.attached?
    errors.add(:cover, "deve ser JPEG, PNG ou WebP") unless cover.content_type.in?(%w[image/jpeg image/png image/webp])
    errors.add(:cover, "deve ter até 1,5 MB") if cover.byte_size > 1.5.megabytes
  end
end
