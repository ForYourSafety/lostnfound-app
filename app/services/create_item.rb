# frozen_string_literal: true

require 'http'

module LostNFound
  # Returns a single item
  class CreateItem
    def initialize(config)
      @config = config
    end

    def call(current_account:, item_params:) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      request = HTTP.auth("Bearer #{current_account.auth_token}")

      tag_ids = item_params[:tags].map(&:to_i) if item_params[:tags]
      # zip contact_type and contact_value into a hash
      contacts = item_params[:contact_type].zip(item_params[:contact_value]).map do |type, value|
        { contact_type: type, value: value }
      end

      item_data = {
        type: item_params[:type],
        name: item_params[:name],
        description: item_params[:description],
        location: item_params[:location],
        time: item_params[:time],
        challenge_question: item_params[:challenge_question],
        owner_name: item_params[:owner_name],
        owner_student_id: item_params[:owner_student_id],
        tag_ids: tag_ids,
        contacts: contacts
      }

      form = {
        data: item_data.to_json
      }

      if !item_params[:images].nil? && item_params[:images].any?
        form[:'images[]'] = item_params[:images].map do |image|
          HTTP::FormData::File.new(image[:tempfile], filename: image[:filename])
        end
      end

      response = request.post("#{@config.API_URL}/items", form: form)

      response.code == 201 ? JSON.parse(response.to_s)['data'] : nil
    end
  end
end
