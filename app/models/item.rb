# frozen_string_literal: true

require 'ostruct'

module LostNFound
  # Behaviors of an item entity
  class Item
    attr_reader :id, :type, :name, :description, :location, :person_info,
                :resolved, :created_by, :contacts, :tags, :policies

    def initialize(item_info)
      process_attributes(item_info['attributes'])
      process_relationships(item_info['relationships'])
    end

    private

    def process_attributes(attributes)
      @id           = attributes['id']
      @type         = attributes['type'] # 0: lost, 1: found
      @name         = attributes['name']
      @description  = attributes['description']
      @location     = attributes['location']
      @person_info  = attributes['person_info']
      @resolved     = attributes['resolved']
      @created_by   = attributes['created_by']
    end

    def process_relationships(relationships)
      return unless relationships

      @created_by = Account.new(relationships['created_by'])
      @tags     = process_tags(relationships['tags'])
      @contacts = process_contacts(relationships['contacts'])
    end

    def process_policies(policies)
      @policies = OpenStruct.new(policies)
    end

    def process_contacts(contacts_info)
      return nil unless contacts_info

      contacts_info.map { |contact_info| Contact.new(contact_info) }
    end

    def process_tags(tag_data)
      return nil unless tag_data

      tag_data.map { |tag_info| Tag.new(tag_info) }
    end
  end
end
