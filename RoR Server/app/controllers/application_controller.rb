class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  include SessionsHelper
  
  before_action :restrict_access, :except => [:register, :signin, :forgot_password, :all_schedules]

    def current_user
      User.find_by :remember_token => @token
    end

    def restrict_access
      authenticate_or_request_with_http_token do |token, options|
        @token = token
        User.exists? remember_token: token
      end
    end
  
end
