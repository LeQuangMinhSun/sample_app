class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by email: params[:email]

    if user && !user.activated && user.authenticated?(:activation, params[:id])
      activate_account user
    else
      fail_activation
    end
  end

  private

  def activate_account user
    user.activate
    log_in user
    flash[:success] = t "flash.activation.success"
    redirect_to user
  end

  def fail_activation
    flash[:danger] = t "flash.activation.fail"
    redirect_to root_url
  end
end
