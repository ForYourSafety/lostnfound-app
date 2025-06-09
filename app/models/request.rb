# frozen_string_literal: true

require_relative 'item'

module LostNFound
  # Behaviors of a request entity
  class Request
    attr_reader :id, :item_id, :requester_id, :message, :status, :created_at, :item, :policies

    def initialize(info)
      process_attributes(info['attributes'])
      process_relationships(info['relationships'])
      process_policies(info['policies'])
    end

    private

    def process_attributes(attributes)
      @id = attributes['id']
      @item_id = attributes['item_id']
      @requester_id = attributes['requester_id']
      @message = attributes['message']
      @status = attributes['status']
      @created_at = attributes['created_at']
    end

    def process_relationships(relationships)
      return unless relationships

      @item = process_item(relationships['item'])
    end

    def process_policies(policies)
      @policies = OpenStruct.new(policies)
    end

    def process_item(item_info)
      return nil unless item_info

      Item.new(item_info)
    end
  end
end
