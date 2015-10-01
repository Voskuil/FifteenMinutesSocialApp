module ApplicationHelper
include AutoHtml
  # Returns the full title on a per-page basis.
  def full_title(page_title = '')
    base_title = "Fifteen Artist Meetup App (Beta)"
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end
  
  def notice
    flash[:notice]
  end

  def alert
    flash[:alert]
  end
end
