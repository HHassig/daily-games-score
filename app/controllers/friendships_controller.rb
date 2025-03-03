class FriendshipsController < ApplicationController
  def create
    @friendship = Friendship.new(follower_id: current_user.id, followee_id: params[:user_id])
    redirect_to users_path, notice: "Followed!" if @friendship.save!
  end

  def destroy
    Friendship.find(params[:id]).destroy!
    redirect_to users_path, notice: "Unfollowed!"
  end
end
