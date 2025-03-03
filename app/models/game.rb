class Game < ApplicationRecord
  belongs_to :network
  has_many :users
  has_many :results
end
