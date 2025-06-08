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
              flash[:notice] = 'Approved / Declined request successfully.'
              routing.redirect(request.referrer || '/')
            end
          end
        end
      end
    end
  end
end
