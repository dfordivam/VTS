module ParticipantHelper

  def sort_link_helper(text, param)
    options = {
        :url => {:action => 'list', :params => params.merge({:sort => param, :page => params[:page]})},
    }
    html_options = {
      :title => "Sort by #{text}",
      :href => url_for(:action => 'list', :params => params.merge({:sort => param, :page => params[:page]}))
    }
    link_to(text, options, html_options)
  end

end
