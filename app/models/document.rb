# frozen_string_literal: true

require_relative 'item'

module LostNFound
  # Behaviors of a contact entity
  class Contact
    attr_reader :id, :contact_type, :value, # basic info
                :item # full item information

    def initialize(info)
      process_attributes(info['attributes'])
      process_included(info['include'])
    end

    private

    def process_attributes(attributes)
      @id           = attributes['id']
      @contact_type = attributes['contact_type']
      @value        = attributes['value']
    end

    def process_included(included)
      @item = Item.new(included['item'])
    end
  end
end
