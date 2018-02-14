class LowQualityTranscoderJob < ActiveJob::Base
  queue_as :default

  rescue_from(Exception) do |exception|
    NL_LOGGER.fatal exception.message
  end

  def perform(vlimit, pipeline)
    vlimit ||= 2
    pipeline ||= ''
    files = Rich::RichFile.where('simplified_type = ? and low_quality_video_downloadpath is null', 'video').where.not('video_downloadpath is null').limit(vlimit)
    
    files.each do |file|
      transcode = Rich::Transcoder.new(file)
      transcode.create_external_low_quality(file, pipeline)
    end
    
  end
end
