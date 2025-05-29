# frozen_string_literal: true

require_relative 'form_base'

module LostNFound
  module Form
    # This form is used to validate items.
    class NewItem < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/new_project.yml')

      params do
        required(:name).filled
        optional(:type).maybe(format?: URI::DEFAULT_PARSER.make_regexp)
        optional(:description).maybe(:string)
        optional(:location).maybe(:string)
        optional(:contact).filled
      end
    end
  end
end
