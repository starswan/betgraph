# frozen_string_literal: true

class CalendarPresenter
  delegate :id, to: :@calendar

  def initialize(calendar)
    @calendar = calendar
  end

  def name_with_sport
    "#{@calendar.sport.name} - #{@calendar.name}"
  end
end
