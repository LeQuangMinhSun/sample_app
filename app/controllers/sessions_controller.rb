class SessionsController < ApplicationController
  before_action :find_by_email, only: :create
  def new; end

  def create
    if @user.authenticate params.dig(:session, :password)
      if @user.activated?
        success_login @user
      else
        account_not_activated
      end
    else
      invalid_email_password
    end
  end

  def destroy
    log_out
    redirect_to root_url, status: :see_other
  end

  private

  def find_by_email
    @user = User.find_by email: params.dig(:session, :email)&.downcase
    return if @user

    flash.now[:danger] = t("flash.users.not_found")
    render :new, status: :unprocessable_entity
  end

  def success_login user
    forwarding_url = session[:forwarding_url]
    reset_session
    log_in user
    params.dig(:session, :remember_me) == "1" ? remember(user) : forget(user)
    redirect_to forwarding_url || user
  end

  def account_not_activated
    flash[:warning] = t "flash.activation.not_activated"
    redirect_to root_url, status: :see_other
  end

  def invalid_email_password
    flash.now[:danger] = t "flash.log_in.invalid_email_password_combination"
    render :new, status: :unprocessable_entity
  end
end
