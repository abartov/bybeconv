class StaticPagesController < ApplicationController
  def view
    @p = StaticPage.find_by_tag(params[:tag])
    if @p.nil?
      flash[:error] = t(:no_such_item)
      redirect_to '/'
    else
      @markdown = MultiMarkdown.new(@p.body).to_html.force_encoding('UTF-8')
    end
  end
end
