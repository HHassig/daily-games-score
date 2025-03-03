class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :games
  has_many :results

  has_many :active_followings, class_name: "Friendship", foreign_key: "follower_id", dependent: :destroy
  has_many :passive_followings, class_name: "Friendship", foreign_key: "followee_id", dependent: :destroy

  has_many :followees, through: :active_followings, source: :followee
  has_many :followers, through: :passive_followings, source: :follower
end
