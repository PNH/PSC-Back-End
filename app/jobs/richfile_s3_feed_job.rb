class RichfileS3FeedJob < ActiveJob::Base
  queue_as :default

  def perform(_foldername = '')
    Rich::Transcoder.s3_bulkfeed(_foldername)
  end
end
