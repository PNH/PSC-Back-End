Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
  config.action_mailer.delivery_method = :letter_opener

  config.transcoder = {
     pipeline_id: Rails.application.secrets.pipeline_id,
     aws_reagion: Rails.application.secrets.aws_reagion,
     aws_access_key: Rails.application.secrets.aws_access_key,
     aws_secret_access_key: Rails.application.secrets.aws_secret_access_key,
     segment_duration: Rails.application.secrets.segment_duration,
     cloudfront_path: Rails.application.secrets.cloudfront_path,
     s3_source_path: Rails.application.secrets.s3_source_path,
     s3_source_name: Rails.application.secrets.s3_source_name,
     s3_external_source_path: Rails.application.secrets.s3_external_source_path,
     s3_external_source_name: Rails.application.secrets.s3_external_source_name,
     s3_subtitle_path: Rails.application.secrets.s3_subtitle_path,
     s3_thumbnail_path: Rails.application.secrets.s3_thumbnail_path,
     aws_sqs_url: Rails.application.secrets.aws_sqs_url
  }
  
  config.cloudfront = {
    cloudfront_key_pair_id: Rails.application.secrets.cloudfront_key_pair_id,
    cloudfront_private_key_path: Rails.application.secrets.cloudfront_private_key_path,
    cloudfront_domain: Rails.application.secrets.cloudfront_domain
  }

  config.s3_source_path = Rails.application.secrets.s3_source_path
ENV['AWS_REGION'] = Rails.application.secrets.aws_reagion
end

Paperclip::Attachment.default_options.merge!(
  storage: :s3,
  bucket: Rails.application.secrets.s3_bucket,
  url: '/system/:class/:attachment/:id/:style/:filename',
  region: Rails.application.secrets.s3_region,
  s3_region: Rails.application.secrets.s3_region,
  s3_credentials: {
    access_key_id: Rails.application.secrets.s3_access_key,
    secret_access_key: Rails.application.secrets.s3_secret_key
  }
)
