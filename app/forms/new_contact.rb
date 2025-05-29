# frozen_string_literal: true

require_relative 'form_base'

module LostNFound
  module Form
    # This form is used to validate contact
    class NewContact < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/new_contact.yml')

      params do
        required(:name).filled(:string)
        required(:contact_type).filled(:string)
      end
    end
  end
end
