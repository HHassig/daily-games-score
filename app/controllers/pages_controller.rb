class PagesController < ApplicationController
  def index
    @games = Game.includes(:network).left_joins(:results).group("games.id").order("COUNT(results.id) DESC")
    if params[:function] == "fetch"
      FetchResult.new.score
      redirect_back fallback_location: root_path
    end
  end
end
