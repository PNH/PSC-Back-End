class RichfileS3FeedJobAudio < ActiveJob::Base
  queue_as :default

  def perform(_foldername = '')
    Rich::Transcoder.s3_bulkfeed_audio(_foldername)
  end
end
