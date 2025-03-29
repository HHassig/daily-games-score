class UsersController < ApplicationController
  before_action :authenticate_user!
  def index
    @users = UsersSetter.new(params[:query]).set
    respond_to do |format|
      format.html
      format.text {
        render partial: "list",
        formats: [:html],
        locals: { users: @users }
      }
    end
  end

  def show
    @user = User.find_by("username ILIKE ?", params[:username])
    @followers = Friendship.where(followee_id: current_user.id)
    @following = Friendship.where(follower_id: current_user.id)
    @games = Result.where(user: current_user).map(&:game).uniq.sort_by { |game| -Result.where(user: current_user).count { |r| r.game == game } }
    @gameday = params[:date].present? ? Gameday.find_or_create_by!(date: params[:date]) : Gameday.find_or_create_by!(date: Date.today.strftime("%Y-%m-%d"))
  end

  def edit
    @user = User.find_by("username ILIKE ?", params[:username])
  end

  def update
    @user = User.find_by("username ILIKE ?", params[:user][:username])
    @user.update!(user_params)
    parse_telegram(@user) unless @user.telegram_username.nil?
    ChatId.new(@user).set unless @user.telegram_username.nil?
    redirect_to user_path(username: @user.username)
  end

  private

  def user_params
    params.require(:user).permit(:username, :email, :telegram_username, :telegram_chat_id)
  end

  def parse_telegram(user)
    user.update!(telegram_username: user.telegram[1..]) if user.telegram_username[0] == "@"
  end
end
