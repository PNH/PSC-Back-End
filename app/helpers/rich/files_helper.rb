module Rich
  module FilesHelper
    def thumb_for_file(file)

      if file.simplified_type == 'video'  
        file.file_status == 1 ? file.url('thumb') : (file.file_status == -1 ?  (asset_path 'rich/no_file.png') : (asset_path 'rich/processing_video.gif'))
      elsif file.simplified_type == 'audio'  
        file.file_status == 1 ?  (asset_path 'rich/icon-mp3.png') : (file.file_status == -1 ?  (asset_path 'rich/no_file.png') : (asset_path 'rich/processing_audio.gif'))
      elsif file.simplified_type == 'image' || file.rich_file_content_type.to_s['image']
        file.rich_file.url(:rich_thumb)
      else
        file.rich_file.url(:rich_thumb)
        case file.rich_file_content_type
        when 'application/pdf'
          asset_path 'rich/icon-pdf.png'
        when 'application/msword'
          asset_path 'rich/icon-doc.png'
        when 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
          asset_path 'rich/icon-docx.png'
        when 'text/html'
          asset_path 'rich/icon-html.png'
        when 'text/css'
          asset_path 'rich/icon-css.png'
        when 'video/x-msvideo'
          asset_path 'rich/icon-avi.png'
        when 'audio/mpeg3' || 'audio/x-mpeg-3' || 'audio/mpeg'
          asset_path 'rich/icon-mp3.png'
        when 'application/zip'
          asset_path 'rich/icon-zip.png'
        when 'text/csv'
          asset_path 'rich/icon-csv.png'
        when 'image/vnd.adobe.photoshop'
          asset_path 'rich/icon-psd.png'
        when 'application/vnd.ms-excel' || 'application/vnd.ms-excel.sheet.binary.macroenabled.12' || ' application/vnd.ms-excel.sheet.macroenabled.12' || 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
          asset_path 'rich/icon-xls.png'
        when 'application/vnd.openxmlformats-officedocument.presentationml.presentation' || 'application/vnd.ms-powerpoint' || 'application/vnd.ms-powerpoint.presentation.macroenabled.12'
          asset_path 'rich/icon-ppt.png'
        when 'application/x-rar-compressed'
          asset_path 'rich/icon-rar.png'
        when 'text/plain'
          asset_path 'rich/icon-txt.png'
        when 'video/mp4' || 'application/mp4' || 'audio/mp4'
          asset_path 'rich/icon-mp4.png'
        else
          asset_path 'rich/icon-unknown.png'
        end
      end
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
