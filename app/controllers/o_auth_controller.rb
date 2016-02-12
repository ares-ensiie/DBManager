class OAuthController < ApplicationController
  skip_before_filter :authenticate_oauth2


  def callback
    set_oauth
    if params[:error] != nil 
      redirect_to "https://ares-ensiie.eu/"
    else
      access_token = @oauth.auth_code.get_token(params[:code], :redirect_uri => callback_url)
      session[:access_token] = access_token.token
      redirect_to root_path
    end
  end
end
