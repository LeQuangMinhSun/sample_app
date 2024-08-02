class ApplicationController < ActionController::Base
  include SessionsHelper
  include Pagy::Backend

  around_action :switch_locale

  private

  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = t "flash.please_log_in"
    redirect_to login_url
  end

  def switch_locale &action
    locale = params[:locale] || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  def default_url_options
    {locale: I18n.locale}
  end
end
