require 'aws-sdk'
class AwsSigner

  def self.cookie_signer(cookies)    
    policy = self.create_policy(5.days.from_now)
    cookies_result = self.csigner.signed_cookie("#{Rails.application.config.cloudfront[:cloudfront_domain]}/*", policy: policy)

    cookies_result.each do |name, value|
      cookies[name] = value
    end
    cookies
  end

  def self.url_signer(url)  
    policy = self.create_policy(5.days.from_now)
    url = self.usigner.signed_url(url, policy: policy)
    url
  end


  private

  def self.usigner
    signer = Aws::CloudFront::UrlSigner.new(
      key_pair_id: Rails.application.config.cloudfront[:cloudfront_key_pair_id],
      private_key_path: Rails.application.config.cloudfront[:cloudfront_private_key_path]
    )
  end

  def self.csigner
    signer = Aws::CloudFront::CookieSigner.new(
      key_pair_id: Rails.application.config.cloudfront[:cloudfront_key_pair_id],
      private_key_path: Rails.application.config.cloudfront[:cloudfront_private_key_path]
    )
  end

  def self.create_policy(expiry)
    {
       "Statement"=> [
          {
             "Resource" => "*",
             "Condition"=>{
                "DateLessThan" =>{"AWS:EpochTime"=> expiry.utc.to_i}
             }
          }
       ]
    }.to_json.gsub(/\s+/,'')
  end

  def self.safe_base64(data)
    Base64.strict_encode64(data).tr('+=/', '-_~')
  end

end
