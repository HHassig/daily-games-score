class UsersSetter
  attr_reader :query

  def initialize(query)
    @query = query
  end

  def set
    return [] if @query.blank?
    User.where("username ILIKE ?", "%#{ActiveRecord::Base.sanitize_sql_like(@query)}%")
  end
end
