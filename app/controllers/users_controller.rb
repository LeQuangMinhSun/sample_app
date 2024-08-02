class UsersController < ApplicationController
  before_action :logged_in_user, except: %i(show new create)
  before_action :correct_user, only: %i(edit update)
  before_action :load_user, except: %i(index new create)
  before_action :admin_user, only: :destroy

  def index
    @pagy, @users = pagy User.name_asc, limit: Settings.page_10
  end

  def following
    @title = t "following.title"
    @pagy, @users = pagy @user.following, limit: Settings.page_10
    render :show_follow
  end

  def followers
    @title = t "follower.title"
    @pagy, @users = pagy @user.followers, limit: Settings.page_10
    render :show_follow
  end

  def show
    @page, @microposts = pagy @user.microposts, limit: Settings.page_10
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params

    if @user.save
      @user.send_activation_email
      flash[:info] = t "flash.activation.check_email"
      redirect_to root_url, status: :see_other
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
