class Drawing < ApplicationRecord
  attr_accessor :file

  after_save :upload_to_s3
  after_destroy_commit :destroy_from_s3

  def upload_to_s3
    s3.upload(compress_file(file.path),
              drawing_key,
              acl: 'public-read',
              content_type: 'image/svg+xml',
              content_encoding: 'gzip',
              cache_control: 'max-age=31536000')

    update_column :url, s3.url(drawing_key)
  end

  def destroy_from_s3
    s3.destroy(drawing_key)
  end

  def drawing_key
    "#{Rails.env}/drawing_#{id}.svg"
  end

  private

    def s3
      @s3 ||= S3.new
    end

    def compress_file(file_name)
      zipped = "#{file_name}.gz"
      Zlib::GzipWriter.open(zipped) do |gz|
        gz.write IO.binread(file_name)
        gz.close
      end
    end
end
