# frozen_string_literal: true

require_relative 'form_base'

module LostNFound
  module Form
    # Form for student information
    class StudentInfo < Dry::Validation::Contract
      params do
        required(:student_id).filled(:string, min_size?: 5)
        required(:name_on_id).filled(:string)
      end
    end
  end
end
