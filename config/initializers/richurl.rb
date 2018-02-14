Paperclip::Attachment.class_eval do
   def url(style_name = default_style, options = {})

      alt_options = (options.present? &&  options == 'no-security') ? {} : options

      if options == true || options == false # Backwards compatibility.
        rurl = @url_generator.for(style_name, default_options.merge(:timestamp => alt_options))
      else
        rurl = @url_generator.for(style_name, default_options.merge(alt_options))
      end

      unless (options.present? &&  options == 'no-security') 
        rurl = rurl.gsub "//s3.amazonaws.com/#{Paperclip::Attachment.default_options[:bucket]}/", Rails.application.config.transcoder[:cloudfront_path]
        rurl = (rurl.include? 'http' || 'https') ? rurl : "http:#{rurl}"
        rurl = AwsSigner.url_signer(rurl.to_s)
        rurl = rurl.partition(':').last
      end
      rurl
    end
end