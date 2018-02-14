class TranscoderJob < ActiveJob::Base
  queue_as :default

  rescue_from(Exception) do |exception|
    NL_LOGGER.fatal exception.message
  end

#  def perform(vlimit,voffset, pipeline)
#    vlimit ||= 2
#    voffset ||= 0
#    pipeline ||= ''
##    files = Rich::RichFile.where('simplified_type = ? and video_downloadpath LIKE ?', "video", "%new-parelli%").limit(vlimit).offset(voffset)
#   files = Rich::RichFile.where('simplified_type = ? and video_downloadpath LIKE ? and file_status = 2', "video", "%parelli-videos%").limit(vlimit).offset(voffset)
##    files = Rich::RichFile.where('simplified_type = ? and video_downloadpath LIKE ?', "video", "%parelli-videos%").limit(vlimit).offset(voffset)
#    files.each do |file|
#      transcode = Rich::Transcoder.new(file)
#      transcode.create_external(file, pipeline)
#    end
#    
  
  def perform(vlimit, pipeline)
    vlimit ||= 2
    pipeline ||= ''
    files = Rich::RichFile.where('file_status = ?', -2).limit(vlimit)
    files.each do |file|
      transcode = Rich::Transcoder.new(file)
      transcode.create_external(pipeline)
    end
    
  end
end
