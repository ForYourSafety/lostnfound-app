# frozen_string_literal: true

require 'ostruct'

module LostNFound
  # Behaviors of an item entity
  class Item
    attr_reader :id, :type, :name, :description, :location, :time, :time_formatted, :image_keys, :image_urls,
                :resolved, :challenge_question, :created_by, :contacts, :tags, :policies

    def initialize(item_info)
      process_attributes(item_info['attributes'])
      process_relationships(item_info['relationships'])
      process_policies(item_info['policies'])
    end

    private

    def process_attributes(attributes) # rubocop:disable Metrics/AbcSize
      @id           = attributes['id']
      @type         = attributes['type']
      @name         = attributes['name']
      @description  = attributes['description']
      @location     = attributes['location']
      @time         = attributes['time'] # seconds since epoch
      @resolved     = attributes['resolved']
      @created_by   = attributes['created_by']
      @challenge_question = attributes['challenge_question']

      if attributes['image_keys'].nil?
        @image_keys = []
        @image_urls = []
      else
        @image_keys = attributes['image_keys'].split(',')
        @image_urls = @image_keys.map { |key| "#{App.config.IMAGE_BASE_URL}/#{key}" }
      end

      @time_formatted = Time.at(@time).strftime('%Y/%m/%d (%a) %I:%M %p') if @time
    end

    def process_relationships(relationships)
      return unless relationships

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
