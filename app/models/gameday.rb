class Gameday < ApplicationRecord
  has_many :results

  validates :date, presence: true, uniqueness: true, format: { with: /\A\d{4}-\d{2}-\d{2}\z/ }

  # Boundary normalizer for user-supplied ?date= params: junk and future dates
  # fall back to today instead of persisting garbage gameday rows.
  def self.for(param)
    date = begin
      Date.iso8601(param.to_s)
    rescue ArgumentError, TypeError
      Date.today
    end
    date = Date.today if date > Date.today
    find_or_create_by!(date: date.strftime("%Y-%m-%d"))
  end
end
