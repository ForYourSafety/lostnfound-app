# frozen_string_literal: true

require 'roda'
require_relative 'app'

module LostNFound
  # Web controller for LostNFound API
  class App < Roda
    route('account') do |routing|
      routing.on do
        # GET /account/[username]
        routing.get String do |username|
          account = GetAccountDetails.new(App.config).call(
            @current_account, username
          )
          @current_account = account
          # binding.irb
          view :account, locals: { account: account }
        rescue GetAccountDetails::InvalidAccount => e
          flash[:error] = e.message
          routing.redirect '/auth/login'
        end

        # POST /account/<registration_token>
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

        # POST /account/[username]/student_info
        routing.post String, 'student_info' do |username|
          unless @current_account.username == username
            flash[:error] = 'You are not authorized to update this account.'
            App.logger.warn "Unauthorized attempt to update account info by #{@current_account.username} on #{username}"
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
    end
  end
end
