class Game < ApplicationRecord
  belongs_to :network
  has_many :results
end
