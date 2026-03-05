Sentry.init do |config|
  config.dsn = 'https://19d1234787f0b688884718368e637e81@o4510985970909184.ingest.us.sentry.io/4510985973661696'
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # Add data like request headers and IP for users,
  # see https://docs.sentry.io/platforms/ruby/data-management/data-collected/ for more info
  config.send_default_pii = true
end