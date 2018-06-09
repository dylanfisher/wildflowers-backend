class S3
  BUCKET = Rails.application.credentials.aws[:bucket]

  attr_reader :client

  def initialize
    @client ||= Aws::S3::Resource.new
  end

  def bucket
    @bucket ||= client.bucket(BUCKET)
  end

  def object(filename)
    bucket.object(filename)
  end

  def upload(string_data, filename, options)
    object(filename).put(body: string_data, **options)
  end

  def url(filename)
    object(filename).public_url
  end

  def destroy(filename)
    object(filename).delete
  end
end
