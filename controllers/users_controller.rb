require_relative '../lib/controller_base'

class UsersController < ControllerBase

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(@params[:user])
    @user.save
    redirect_to '/users'
  end

end
