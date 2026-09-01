class FetchScoresJob < ApplicationJob
  queue_as :default

  def perform
    FetchResult.new.score
  end
end
