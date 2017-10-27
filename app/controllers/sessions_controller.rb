class SessionsController < ApplicationController
  def create
    @auth_hash = request.env['omniauth.auth']

    @merchant = Merchant.find_by(oauth_uid: @auth_hash['uid'], oauth_provider: @auth_hash['provider'])

    if @merchant
      session[:merchant_id] = @merchant.id
      flash[:status] = :success
      flash[:result_text] = "You successfully logged in as #{@merchant.username}."
    else
      @merchant = Merchant.new oauth_uid: @auth_hash['uid'], oauth_provider: @auth_hash['provider'], username: @auth_hash['info']['nickname'], email: @auth_hash['info']['email']
      if @merchant.save
        session[:merchant_id] = @merchant.id
        flash[:status] = :success
        flash[:result_text] = "You successfully logged in as new user #{@merchant.username}."
      else
        flash[:status] = :error
        flash[:result_text] = "Unable to save user :( "
      end
    end#ifelse
    redirect_to merchant_path(@merchant.id)
  end #create

  def logout
    session[:merchant_id] = nil
    flash[:status] = :success
    flash[:result_text] = "You successfully logged out."
    redirect_to root_path
  end

  # def index
  # end
end
