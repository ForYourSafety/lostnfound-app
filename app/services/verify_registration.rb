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

    def call(registration_data)
      reg_details = registration_data.to_h
      registration_token = SecureMessage.encrypt(reg_details)
      reg_details['verification_url'] =
        "#{@config.APP_URL}/auth/register/#{registration_token}"
      response = HTTP.post("#{@config.API_URL}/auth/register",
                           json: reg_details)

      raise(VerificationError) unless response.code == 202

      JSON.parse(response.to_s)
    rescue HTTP::ConnectionError
      raise(ApiServerError)
    end
  end
end
