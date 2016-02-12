class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :authenticate_oauth2


  def set_oauth
    @oauth = OAuth2::Client.new(OAUTH_CONFIG['APP_ID'], OAUTH_CONFIG['APP_SECRET'], :site => OAUTH_CONFIG['OAUTH_PROVIDER'], :ssl => {:verify => false})
  end

  def authenticate_oauth2
    set_oauth
    if session[:access_token]
      access_token = OAuth2::AccessToken.new(@oauth, session[:access_token])
      begin
        @user = JSON.parse(access_token.get("/api/v1/me.json").body)
        return
      rescue Exception => e
        puts e
      end
    end
    redirect_to @oauth.auth_code.authorize_url(:redirect_uri => callback_url)
  end
end
