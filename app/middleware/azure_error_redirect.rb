class AzureErrorRedirect
  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call(env)
  rescue JWT::DecodeError => error
    request_path = Rack::Request.new(env).path
    Rollbar.log('error', "#{request_path}::#{error} - redirecting to new session path")
    Rails.logger.error("#{request_path}::#{error} - redirecting to new session path")
    [301, { 'Location' => Rails.application.routes.url_helpers.new_sessions_path }, ['Something went wrong']]
  end
end
