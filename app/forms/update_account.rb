# frozen_string_literal: true

require_relative 'form_base'

module LostNFound
  module Form
    # Form for updating account information
    class UpdateAccount < Dry::Validation::Contract
      params do
        required(:email).filled(format?: EMAIL_REGEX)
        required(:student_id).filled(:string, min_size?: 5)
        required(:name_on_id).filled(:string)
      end
    end
  end
end
