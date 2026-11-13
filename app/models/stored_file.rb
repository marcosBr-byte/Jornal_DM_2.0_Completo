# Small cover files stored outside Render's ephemeral filesystem.
class StoredFile < ApplicationRecord
  validates :key, presence: true, uniqueness: true
end
