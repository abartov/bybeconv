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
    elsif @author.toc.nil?
      flash[:error] = I18n.t('no_toc_yet')
      redirect_to '/'
    else
      old_toc = @author.toc.toc
      @toc = @author.toc.refresh_links
      if @toc != old_toc # update the TOC if there have been HtmlFiles published since last time, regardless of whether or not further editing would be saved.
        @author.toc.toc = @toc
        @author.toc.save!
      end
      markdown_toc = toc_links_to_markdown_links(@toc)
      @html = MultiMarkdown.new(markdown_toc).to_html.force_encoding('UTF-8')
      @toc_timestamp = @author.toc.updated_at
    end
  end
end
