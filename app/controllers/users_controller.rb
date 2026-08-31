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
    @user = User.find_by!("username ILIKE ?", params[:username])
    @followers = Friendship.where(followee_id: current_user.id)
    @following = Friendship.where(follower_id: current_user.id)
    counts = Result.where(user: @user).group(:game_id).count
    @games = Game.where(id: counts.keys).sort_by { |game| -counts[game.id] }
    @gameday = Gameday.for(params[:date])
  end

  def edit
    @user = User.find_by("username ILIKE ?", params[:username])
  end

  def update
    @user = current_user
    @user.update!(user_params)
    @user.update!(telegram_username: @user.telegram_username[1..]) if @user.telegram_username&.start_with?("@")
    ChatId.new(@user).set if @user.telegram_username.present?
    redirect_to user_path(username: @user.username)
  end

  private

  def user_params
    params.require(:user).permit(:username, :email, :telegram_username, :telegram_chat_id)
  end
end
