# frozen_string_literal: true

require_relative 'item'

module LostNFound
  # Collection of request entities
  class Requests
    attr_reader :all

    def initialize(requests_list)
      @all = requests_list.map do |request_info|
        Request.new(request_info)
      end
    end
  end
end
