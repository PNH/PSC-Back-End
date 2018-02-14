Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Enable Rack::Cache to put a simple HTTP cache in front of your application
  # Add `rack-cache` to your Gemfile before enabling this.
  # For large-scale production use, consider using a caching reverse proxy like
  # NGINX, varnish or squid.
  # config.action_dispatch.rack_cache = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.serve_static_files = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :uglifier
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # `config.assets.precompile` and `config.assets.version` have moved to config/initializers/assets.rb

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :error

  # Prepend all log lines with the following tags.
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups.
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = 'http://assets.example.com'

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  config.action_mailer.smtp_settings = {
    address: Rails.application.secrets.email_provider_host,
    port: Rails.application.secrets.email_provider_port,
    domain: Rails.application.secrets.email_provider_domain,
    authentication: Rails.application.secrets.email_provider_authentication,
    enable_starttls_auto: true,
    tls: true,
    user_name: Rails.application.secrets.email_provider_username,
    password: Rails.application.secrets.email_provider_password
  }
  config.action_mailer.default_url_options = {
    host: Rails.application.secrets.host,
    protocol: 'http://'
  }
  Rails.application.routes.default_url_options[:host] = Rails.application.secrets.host

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

