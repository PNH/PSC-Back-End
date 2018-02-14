module CommonControllerConcern
  extend ActiveSupport::Concern

  included do

    def get_subtitles_for_api(path)
      langs = ['EN','DE','FR']
      lang_path = []
      unless path.empty?
        path = File.basename(path)
        s3_subtitle_path = Rails.application.config.transcoder[:s3_subtitle_path]

        langs.each do |lang|
             vtt_path = path.gsub ".m3u8", "_#{lang}.vtt"
             vtt_path = "#{s3_subtitle_path}#{vtt_path}"
             if is_file_exists(vtt_path)
               lang_path << {:language => lang, :source => vtt_path}
             end          
        end
      end
      lang_path
    end

    def get_subtitles(path)
      langs = [{:code => 'EN', :detail => 'English'},{:code => 'DE', :detail => 'German'},{:code => 'FR', :detail => 'French'}]
      lang_path = []
      unless path.empty?
        path = File.basename(path)
        s3_subtitle_path = Rails.application.config.transcoder[:s3_subtitle_path]

        langs.each do |lang|
             vtt_path = path.gsub ".m3u8", "_#{lang[:code]}.vtt"
             vtt_path = "#{s3_subtitle_path}#{vtt_path}"
             if is_file_exists(vtt_path)
              if lang[:code] == 'EN'
                lang_path << {:file => vtt_path, :label => lang[:detail], :kind => 'captions', :default => 'true'}
              else
                lang_path << {:file => vtt_path, :label => lang[:detail], :kind => 'captions'}
              end               
             end          
        end
      end
      lang_path
    end

    def is_file_exists(path)

      begin
      path =  (path.include? 'http' || 'https') ? path : "https:#{path}"
      uri = URI(path)
      if uri.host.present?

        request = Net::HTTP.new uri.host
        response= request.request_head uri.path
        response.present? && response.code.to_i == 200
      end
      rescue => error
        false
      end
    end
  end  
end