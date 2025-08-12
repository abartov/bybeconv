require "active_storage/service/s3_service"
module ActiveStorage
  class Service::S3HttpsService < Service::S3Service
    def url(key, *options)
      super(key, *options).gsub /http(s)?:/, ''
    end
  end
end

