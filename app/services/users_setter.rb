class UsersSetter
  attr_reader :query

  def initialize(query)
    @query = query
  end

  def set
    @query.present? ? User.all.where("username ILIKE '%#{@query}%'") : []
  end
end
