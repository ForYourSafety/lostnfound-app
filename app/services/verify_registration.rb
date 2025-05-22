# frozen_string_literal: true

require 'http'

module LostNFound
  # Returns an authenticated user, or nil
  class VerifyRegistration
    class VerificationError < StandardError; end
    class ApiServerError < StandardError; end

    ONE_HOUR = 60 * 60
    ONE_DAY = ONE_HOUR * 24
    ONE_WEEK = ONE_DAY * 7
    ONE_MONTH = ONE_WEEK * 4
    ONE_YEAR = ONE_MONTH * 12

    def initialize(config)
      @config = config
    end

    def expires(expiration)
      (Time.now + expiration).to_i
    end

    def call(registration_data) # rubocop:disable Metrics/AbcSize
      registration_data['exp'] = Time.now.to_i + expires(ONE_HOUR)

      registration_token = SecureMessage.encrypt(registration_data)
      registration_data['verification_url'] =
        "#{@config.APP_URL}/auth/register/#{registration_token}"

      response = HTTP.post("#{@config.API_URL}/auth/register",
                           json: registration_data)
      body = JSON.parse(response.to_s)

      raise(VerificationError, body['message']) unless response.code == 202

      body
    rescue HTTP::ConnectionError
      raise(ApiServerError)
    end
  end
end
