require "active_storage/service"
require "digest"

class ActiveStorage::Service::DatabaseService < ActiveStorage::Service
  MAX_BYTES = 1.5.megabytes.to_i
  CHUNK_BYTES = 64.kilobytes

  def upload(key, io, checksum: nil, **)
    instrument :upload, key: key do
      data = io.read(MAX_BYTES + 1).to_s.b
      raise ActiveStorage::IntegrityError, "Cover exceeds the 1.5 MB limit" if data.bytesize > MAX_BYTES
      if checksum && !ActiveSupport::SecurityUtils.secure_compare(Digest::MD5.base64digest(data), checksum)
        raise ActiveStorage::IntegrityError, "Checksum mismatch"
      end
      record = StoredFile.find_or_initialize_by(key: key)
      record.update!(data: data)
    end
  end

  def download(key)
    instrument :download, key: key do
      data = file_data(key)
      if block_given?
        offset = 0
        while offset < data.bytesize
          yield data.byteslice(offset, CHUNK_BYTES)
          offset += CHUNK_BYTES
        end
      else
        data
      end
    end
  end

  def download_chunk(key, range)
    instrument :download_chunk, key: key, range: range do
      file_data(key).byteslice(range) || "".b
    end
  end

  def delete(key)
    instrument(:delete, key: key) { StoredFile.where(key: key).delete_all }
  end

  def delete_prefixed(prefix)
    instrument :delete_prefixed, prefix: prefix do
      StoredFile.where("key LIKE ?", "#{StoredFile.sanitize_sql_like(prefix)}%").delete_all
    end
  end

  def exist?(key)
    instrument(:exist, key: key) { StoredFile.exists?(key: key) }
  end

  private

  def file_data(key)
    record = StoredFile.find_by(key: key)
    raise ActiveStorage::FileNotFoundError unless record
    record.data.b
  end
end
