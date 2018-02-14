class TranscoderNotificationJob < ActiveJob::Base
  queue_as :default

  rescue_from(Exception) do |exception|
    NL_LOGGER.fatal exception.message
  end

  def perform(_prefix = '')
    Rich::Transcoder.read_transcode_notifications    
  end
end
