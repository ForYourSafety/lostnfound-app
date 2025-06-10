# frozen_string_literal: true

require 'roda'
require_relative 'app'

module LostNFound
  # Web controller for LostNFound API
  class App < Roda
    route('account') do |routing|
      routing.on do
        routing.on 'register' do
          # POST /account/register/<registration_token>
          routing.post String do |registration_token|
            passwords = Form::Passwords.new.call(routing.params)

            if passwords.failure?
              flash[:error] = Form.message_values(passwords)
              routing.redirect "#{App.config.APP_URL}/auth/register/#{registration_token}"
            end

            new_account = VerifyRegistrationToken.new(App.config).call(registration_token)
            CreateAccount.new(App.config).call(
              email: new_account['email'],
              username: new_account['username'],
              password: routing.params['password']
            )

            flash[:notice] = 'Account created! Please login'
            routing.redirect '/auth/login'
          rescue CreateAccount::InvalidAccount => e
            App.logger.warn "Invalid account creation attempt: #{e.inspect}\n#{e.backtrace.join("\n")}"
            flash[:error] = e.message
            routing.redirect '/auth/register'
          rescue StandardError => e
            App.logger.warn "Unexpected error during account creation: #{e.inspect}\n#{e.backtrace.join("\n")}"
            flash[:error] = 'An unexpected error occurred while creating your account. Please try again.'
            routing.redirect(
              "#{App.config.APP_URL}/auth/register/#{registration_token}"
            )
          end
        end

        routing.on String do |username|
          routing.on 'requests' do
            # GET /account/<username>/requests
            routing.get do
              unless @current_account.logged_in?
                flash[:error] = 'You must be logged in to view your requests.'
                routing.redirect '/auth/login'
              end

              requests_data = GetAccountRequests.new(App.config).call(
                current_account: @current_account
              )

              if requests_data.nil?
                response.status = 400
                flash[:error] = 'Failed to retrieve requests.'
                routing.redirect(request.referrer || '/')
              end

              requests = Requests.new(requests_data)

              view :request_list, locals: { current_user: @current_account, requests:, for_item: nil, to_me: false }
            end
          end

          routing.on 'items' do
            # GET /account/<username>/items
            routing.get do
              unless @current_account.logged_in?
                flash[:error] = 'You must be logged in to view your items.'
                routing.redirect '/auth/login'
              end

              items_data = GetAccountItems.new(App.config).call(
                current_account: @current_account
              )

              if items_data.nil?
                response.status = 400
                flash[:error] = 'Failed to retrieve items.'
                routing.redirect(request.referrer || '/')
              end

              items = Items.new(items_data)

              all_tags_data = GetAllTags.new(App.config).call(@current_account) || []
              all_tags = Tags.new(all_tags_data)

              view :item_list, locals: { current_user: @current_account, items:, all_tags:, mine: true }
            end
          end

          routing.on 'student_info' do
            # POST /account/[username]/student_info
            routing.post do
              unless @current_account.username == username
                flash[:error] = 'You are not authorized to update this account.'
                App.logger.warn "Unauthorized attempt to update account infoby #{@current_account.username} on #{username}"
                routing.redirect "/account/#{@current_account.username}"
              end

              student_info_form = Form::StudentInfo.new.call(routing.params)

              if student_info_form.failure?
                flash[:error] = Form.message_values(student_info_form)
                App.logger.info 'Student info validation failed'
                routing.redirect "/account/#{@current_account.username}"
              end

              student_info = AddStudentInfo.new(App.config).call(
                current_account: @current_account,
                student_info_params: student_info_form.to_h
              )
              if student_info
                flash[:notice] = 'Student information saved successfully.'
                latest_account_from_db = GetAccountDetails.new(App.config).call(
                  @current_account, username
                )
                @current_account = latest_account_from_db
              else
                flash[:error] = 'Failed to save student information.'
                App.logger.warn "API call to update student info failed for #{@current_account.username}"
              end
              routing.redirect "/account/#{@current_account.username}"
            rescue StandardError
              App.logger.warn 'Error while saving student info'
              flash[:error] = 'An unexpected error occurred while saving your student information. Please try again.'
              routing.redirect "/account/#{@current_account.username}"
            end
          end

          # GET /account/<username>
          routing.get do
            account = GetAccountDetails.new(App.config).call(
              @current_account, username
            )
            view :account, locals: { account: account }
          rescue GetAccountDetails::InvalidAccount => e
            flash[:error] = e.message
            routing.redirect '/auth/login'
          end
        end
      end
    end
  end
end
