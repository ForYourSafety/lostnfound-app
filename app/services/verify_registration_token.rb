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

      return unless Time.now.to_i > exp

      # Token has expired
      raise(VerifyRegistration::VerificationError,
            'Registration token has expired. Please submit a new request again.')
    rescue StandardError
      # Token is invalid
      raise(VerifyRegistration::VerificationError, 'Invalid token')
    end
  end
end
