# frozen_string_literal: true

require 'http'

module LostNFound
  # Returns registration data if the token is valid
  class VerifyRegistrationToken
    class VerificationError < StandardError; end

    def initialize(config)
      @config = config
    end

    def call(registration_token)
      new_account = SecureMessage.new(registration_token).decrypt
      exp = new_account.delete('exp')
      return new_account unless Time.now.to_i > exp

      # Token has expired
      raise(VerifyRegistrationToken::VerificationError,
            'Registration token has expired. Please submit a new request again.')
    rescue StandardError => e
      # Token is invalid
      App.logger.warn "Invalid registration token: #{e.inspect}\n#{e.backtrace.join("\n")}"
      raise(VerifyRegistrationToken::VerificationError, 'Invalid token')
    end
  end
end
