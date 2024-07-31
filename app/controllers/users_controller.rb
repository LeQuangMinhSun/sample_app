class UsersController < ApplicationController
  before_action :logged_in_user, except: %i(show new create)
  before_action :correct_user, only: %i(edit update)
  before_action :load_user, except: %i(index new create)
  before_action :admin_user, only: :destroy

  def index
    @pagy, @users = pagy User.name_asc, items: Settings.page_10
  end

  def show
    @user = User.find_by id: params[:id]
    return if @user

    flash[:warning] = t "flash.users.not_found"
    redirect_to root_path
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params

    if @user.save
      flash[:success] = t "flash.create_account.success"
      redirect_to @user, status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    flash[:warning] = t "flash.users.not_found"
    redirect_to root_path
  end

  def update
    if @user.update user_params
      flash[:success] = t "flash.users.update.success"
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t "flash.users.delete.success"
    else
      flash[:danger] = t "flash.users.delete.fail"
    end
    redirect_to users_path
  end

  private

  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = t "flash.please_log_in"
    redirect_to login_url
  end

  def correct_user
    return if current_user?(@user)

    flash[:error] = t "flash.incorrect_user"
    redirect_to root_path
  end

  def load_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:danger] = t "flash.users.not_found"
    redirect_to root_url
  end

  def user_params
    params.require(:user).permit User::USER_PARAMS
  end

  def admin_user
    redirect_to root_path unless current_user.admin?
  end
end
