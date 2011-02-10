# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def increment_year(updated_date)
    add_year = 0

    updated_year = updated_date.strftime("%Y").to_i

    today = Time.now
    today_year = today.strftime("%Y").to_i

    if today_year > updated_year
      diff = (today - updated_date).round
      add_year = diff/(365 * 24 * 60 * 60)
    end

    return add_year
  end
end
