require 'oauth2'

class HomeController < ApplicationController
  MyGuessOfIntranetIp = `ifconfig`.scan(/inet ([\.\d]+)/).flatten.find { |x| x != '127.0.0.1' }

  APPLICATION_ID = '32258b408332a9504bf3d048a5879ed3b9978474d408b2f3c9bab1cb8a03cda3'
  APPLICATION_SECRET = '96a730fb7a806fc1f6cb8e52b7d1f40b5314126978dad977bfcb5682c922760c'

  CALLBAK_URL = "http://#{MyGuessOfIntranetIp}:3001/auth/"
  PROVIDER_SITE = "http://#{MyGuessOfIntranetIp}:3000/"

  def rum(resource_path, method: :get, post_body: {})
    @oauth = OAuth2::Client.new APPLICATION_ID, APPLICATION_SECRET,
                                site: PROVIDER_SITE # , token_method: :post

    begin
      if session[:rum_token]
        @token = OAuth2::AccessToken.new @oauth, session[:rum_token]
        response = @token.send method, resource_path, body: post_body
        return JSON.parse response.body
      end
    rescue OAuth2::Error # rubocop:disable HandleExceptions
      # we let this pass, and redirect as if no rum_token exists
    end

    redirect_to @oauth.auth_code.authorize_url(redirect_uri: CALLBAK_URL)
  end

  def index
    @current_user = rum '/api/user/info'
  end

  def auth
    grant_token = params[:code]

    @oauth = OAuth2::Client.new APPLICATION_ID, APPLICATION_SECRET,
                                site: PROVIDER_SITE

    response = @oauth.auth_code.get_token grant_token, redirect_uri: CALLBAK_URL
    session[:rum_token] = response.token
    redirect_to '/'
  end

  def logout
    rum '/api/user/logout', method: :post
    session.clear
    redirect_to '/'
  end
end
