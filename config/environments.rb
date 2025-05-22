# frozen_string_literal: true

require 'delegate'
require 'roda'
require 'figaro'
require 'logger'
require 'rack/ssl-enforcer'
require 'rack/session'
require 'rack/session/redis'
require_relative '../require_app'

require_app('lib')
module LostNFound
  # Configuration for the API
  class App < Roda
    plugin :environments

    # Environment variables setup
    Figaro.application = Figaro::Application.new(
      environment:,
      path: File.expand_path('config/secrets.yml')
    )
    Figaro.load
    def self.config = Figaro.env

    # Secure session configuration
    ONE_MONTH = 30 * 24 * 60 * 60
    SecureMessage.setup(ENV.delete('MSG_KEY'))

    # HTTP Request logging
    configure :development, :production do
      plugin :common_logger, $stdout
    end

    # Custom events logging
    LOGGER = Logger.new($stderr)
    def self.logger = LOGGER

    # Console/Pry configuration
    configure :development, :test do
      # Suppresses log info/warning outputs in dev/test environments
      logger.level = Logger::ERROR

      # NOTE: env var REDIS_URL only used to wipe the session store (ok to be nil)
      SecureSession.setup(ENV.fetch('REDIS_URL', nil)) # REDIS_URL used again below

      # use Rack::Session::Cookie,
      #     expire_after: ONE_MONTH, secret: config.SESSION_SECRET

      use Rack::Session::Pool,
          expire_after: ONE_MONTH

      # use Rack::Session::Redis,
      #     expire_after: ONE_MONTH,
      #     redis_server: @redis_url

      # Allows binding.pry to be used in development
      require 'pry'

      # Allows running reload! in pry to restart entire app
      def self.reload!
        exec 'pry -r ./spec/test_load_all'
      end
    end
    configure :production do
      use Rack::SslEnforcer, hsts: true

      @redis_url = ENV.delete('REDISCLOUD_URL')
      SecureSession.setup(@redis_url) # Only used for wiping redis sessions with rake session:wipe

      use Rack::Session::Redis,
          expire_after: ONE_MONTH,
          redis_server: @redis_url
    end
  end
end
