class PasswordResetsController < ApplicationController
  before_action :load_user, :valid_user, :check_expiration,
                only: %i(edit update)
  def new; end

  def create
    @user = User.find_by email: params.dig(:password_reset, :email)&.downcase
    if @user
      success_send_email
    else
      fail_send_emai
    end
  end

  def edit; end

  def update
    if user_params[:password].empty?
      @user.errors.add :password, t(".error")
      render :edit
    elsif @user.update user_params
      log_in @user
      @user.update_column :reset_digest, nil
      flash[:success] = t "flash.password_resets.success.reset"
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def success_send_email
    @user.create_reset_digest
    @user.send_password_reset_email
    flash[:info] = t "flash.password_resets.success.send_email"
    redirect_to root_url
  end

  def fail_send_emai
    flash.now[:danger] = t "flash.password_resets.fail.send_email"
    render :new, status: :unprocessable_entity
  end

  def load_user
    @user = User.find_by email: params[:email]
    return if @user

    flash[:danger] = t "flash.users.not_found"
    redirect_to root_url
  end

  def valid_user
    return if @user.activated && @user.authenticated?(:reset, params[:id])

    flash[:danger] = t "flash.users.not_activated"
    redirect_to root_url
  end

  def user_params
    params.require(:user).permit User::PASSWORD_PARAMS
  end

  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = t "flash.password_resets.expired"
    redirect_to new_password_reset_url
  end
end
