# -*- coding: utf-8 -*-
class UsersController < ApplicationController
  def index
    if session['user_id'] #cookieにしてね
      @user = User.find.(session['user_id'])
      @loged = 'こんにちはこんにちは!!'
    else
      #cookieないよー
    end
  end

  def login
    require('pp')
    callback_url = 'http://localhost:3000/callback'
    consumer = oauth_consumer

    pp consumer

    request_token = consumer.get_request_token :oauth_callback => callback_url
    pp request_token

    session['request_token'] = request_token.token
    session['request_secret'] = request_token.secret

    redirect_to request_token.authorize_url
  end

  def callback
    require('pp')
    consumer = oauth_consumer
    request_token = OAuth::RequestToken.new(
                                            consumer,
                                            session['request_token'],
                                            session['request_secret'])
    access_token = request_token.get_access_token({ },
                                                  :oauth_token => params['oauth_token'],
                                                  :oauth_verfier => params['oauth_verifier'])

    session['access_token'] = access_token.token
    session['access_secret'] = access_token.secret

    Twitter.configure do |config|
      config.consumer_key = ''
      config.consumer_secret = ''
      config.oauth_token = access_token.token
      config.oauth_token_secret = access_token.secret
    end

    @client = Twitter::Client.new
    @profile = @client.verify_credentials
    #pp @profile
    pp @profile.id

    user = Users.where('user_id = ?', @profile.id).first

    if user
      user = user
    else
      user = Users.create(
                         :screen_name => @profile.screen_name,
                         :user_id => @profile.id,
                         :access_token => access_token.token,
                         :access_token_secret => access_token.secret
                         )
    end

    session[:user_id] = user.id

    #user = Users.find(user.id)
    #user.last_login_at = Time.now
    #user.save

    redirect_to :action => :index

  end

  private
  def oauth_consumer
    config = Rails.application.config.base
    OAuth::Consumer.new(
      config.twitter.consumer_key,
      config.twitter.consumer_secret,
      :site => 'http://twitter.com')
  end

end
