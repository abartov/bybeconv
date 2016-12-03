class AuthorsController < ApplicationController
  def index
  end

  def show
  end

  def edit
  end

  def list
  end

  def toc
    @author = Person.find(params[:id])
    @tabclass = set_tab('authors')
    @print_url = url_for(action: :print, id: @author.id)
  end
  def print
  end

  def edit_toc
    @author = Person.find(params[:id])
    if @author.nil?
      flash[:error] = I18n.t('no_such_item')
      redirect_to '/'
    else
      @toc = @author.toc.refresh_links
      @html = MultiMarkdown.new(@toc).to_html.force_encoding('UTF-8')
    end
  end
end
