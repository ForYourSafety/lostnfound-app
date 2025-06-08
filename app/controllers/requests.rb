# frozen_string_literal: true

require 'roda'

module LostNFound
  # Web controller for LostnFound API
  class App < Roda
    route('requests') do |routing|
      routing.on do
        routing.on String do |request_id|
          unless @current_account.logged_in?
            flash[:error] = 'You must be logged in to manipulate a request.'
            routing.redirect '/auth/login'
          end

          routing.on 'delete' do
            # POST /requests/:request_id/delete
            routing.post do
              unless @current_account.logged_in?
                flash[:error] = 'You must be logged in to delete a request.'
                routing.redirect '/auth/login'
              end

              result = DeleteRequest.new(App.config).call(
                current_account: @current_account,
                request_id: request_id
              )

              unless result
                response.status = 404
                flash[:error] = 'Request could not be deleted.'
                routing.redirect(request.referrer || '/')
              end

              flash[:notice] = 'Request deleted successfully.'
              routing.redirect(request.referrer || '/')
            end
          end

          routing.on 'reply' do
            routing.post do
              action = routing.params['action']
              unless %w[approve decline].include?(action)
                response.status = 400
                flash[:error] = 'Invalid action specified.'
                routing.redirect(request.referrer || '/')
              end

              status = action == 'approve' ? 'approved' : 'declined'

              result = ReplyRequest.new(App.config).call(
                current_account: @current_account,
                request_id: request_id,
                status: status
              )

              unless result
                response.status = 400
                flash[:error] = "Request could not be #{status}."
                routing.redirect(request.referrer || '/')
              end

              flash[:notice] = "The request has been #{status}."
              routing.redirect(request.referrer || '/')
            end
          end
        end

        routing.is do
          # GET /requests
          # Requests to me
          routing.get do
            unless @current_account.logged_in?
              flash[:error] = 'You must be logged in to view requests.'
              routing.redirect '/auth/login'
            end

            requests_data = GetRequests.new(App.config).call(
              current_account: @current_account
            )

            if requests_data.nil?
              response.status = 400
              flash[:error] = 'Failed to retrieve requests.'
              routing.redirect(request.referrer || '/')
            end

            requests = Requests.new(requests_data)

            view :request_list, locals: { current_user: @current_account, requests:, for_item: nil, to_me: true }
          end
        end
      end
    end
  end
end
