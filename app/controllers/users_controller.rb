class UsersController < ApplicationController
  def index
    @user = User.all.find()
    if session['user_id'] #cookieにしてね -> 意識低いのでやめました。
      #@user = User.find.(session['user_id'])
      session['status'] = 1
      
      
    else
      #cookieないよー
    end
    require('pp')
    pp @user
  end

  def login
    callback_url = 'http://localhost:3000/callback'
    consumer = oauth_consumer


    request_token = consumer.get_request_token :oauth_callback => callback_url

    session['request_token'] = request_token.token
    session['request_secret'] = request_token.secret

    redirect_to request_token.authorize_url
  end

  def callback
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

    user = User.where('user_id = ?', @profile.id).first

    if user #DBにいる
      session[:touch] = 'touch'
      #session['user_id'] = user.user_id
    else #後新規一名様。
      user = User.create(
                         :screen_name => @profile.screen_name,
                         :user_id => @profile.id,
                         :access_token => access_token.token,
                         :access_token_secret => access_token.secret
                         )
      session[:touch] = 'first'
      
    end

    session[:user_id] = user.id
    
    redirect_to :action => 'new'
  end

  def new
    @user = User.find(session[:user_id])
  end
  
  def update
    data = params[:user]
    
    year = data['birthday(1i)']
    month = data['birthday(2i)']
    day = data['birthday(3i)']
    
    if /[1-9]/ =~ month
      month = '0' + month
    end

    if /[1-9]/ =~ day
      day = '0' + day
    end

    birthday = year + '-' + month + '-' + day
    
    user = User.find(session['user_id'])
    if user
      user.birthday = birthday
      user.save()
    else
    end
    redirect_to :action => 'index'
  end
    
  
  private
  def oauth_consumer
    config = Rails.application.config
    OAuth::Consumer.new(
      config.base['twitter']['consumer_key'],
      config.base['twitter']['consumer_secret'],
      :site => 'http://twitter.com')
  end


end
