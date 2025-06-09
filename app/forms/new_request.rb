# frozen_string_literal: true

require_relative 'form_base'

module LostNFound
  module Form
    # This form is used to validate a new request.
    class NewRequest < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/new_request.yml')

      params do
        required(:message).filled(:string)
      end
    end
  end
end
