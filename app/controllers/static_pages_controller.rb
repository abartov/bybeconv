class StaticPagesController < ApplicationController
  def view
    @p = StaticPage.find_by_tag(params[:tag])
    if @p.nil?
      flash[:error] = t(:no_such_item)
      redirect_to '/'
    else
      @page_title = "#{@p.title} – #{t(:project_ben_yehuda)}"
      @ltr = true if @p.ltr
      @markdown = @p.prepare_markdown.gsub(/<figcaption>.*?<\/figcaption>/,'')
    end
  end
end
