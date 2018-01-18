class StaticPagesController < ApplicationController
  def view
    @p = StaticPage.find_by_tag(params[:tag])
    if @p.nil?
      flash[:error] = t(:no_such_item)
      redirect_to '/'
    else
      @markdown = @p.prepare_markdown
    end
  end
end
