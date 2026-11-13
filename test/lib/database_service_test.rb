require "test_helper"
require "digest"

class DatabaseServiceTest < ActiveSupport::TestCase
  setup do
    @service = ActiveStorage::Blob.services.fetch("database")
    @data = "capa de teste com conteúdo persistente".b
    @checksum = Digest::MD5.base64digest(@data)
  end

  test "upload downloads and streams files from PostgreSQL" do
    @service.upload("cover-key", StringIO.new(@data), checksum: @checksum)
    assert @service.exist?("cover-key")
    assert_equal @data, @service.download("cover-key")
    assert_equal @data.byteslice(1..5), @service.download_chunk("cover-key", 1..5)
    chunks = []
    @service.download("cover-key") { |chunk| chunks << chunk }
    assert_equal @data, chunks.join
    @service.open("cover-key", checksum: @checksum) do |file|
      assert_equal @data, file.read
    end
    @service.delete("cover-key")
    assert_not @service.exist?("cover-key")
    assert_raises(ActiveStorage::FileNotFoundError) { @service.download("cover-key") }
  end

  test "checksum and maximum file size are enforced before persistence" do
    assert_no_difference "StoredFile.count" do
      assert_raises(ActiveStorage::IntegrityError) do
        @service.upload("invalid", StringIO.new(@data), checksum: Digest::MD5.base64digest("other"))
      end
      assert_raises(ActiveStorage::IntegrityError) do
        @service.upload("oversized", StringIO.new("a" * (ActiveStorage::Service::DatabaseService::MAX_BYTES + 1)))
      end
    end
  end

  test "prefix deletion treats SQL wildcards as literal characters" do
    @service.upload("news%_cover", StringIO.new(@data))
    @service.upload("newsXX_cover", StringIO.new(@data))
    @service.delete_prefixed("news%_")
    assert_not @service.exist?("news%_cover")
    assert @service.exist?("newsXX_cover")
  end

  test "a fresh service instance reads the same persistent object" do
    @service.upload("persistent-key", StringIO.new(@data), checksum: @checksum)
    fresh_service = ActiveStorage::Service.configure(:database, Rails.application.config.active_storage.service_configurations)
    assert_equal @data, fresh_service.download("persistent-key")
  end
end
