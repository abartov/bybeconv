require 'diffy'

class AuthorsController < ApplicationController
  before_filter :require_editor, only: [:index, :show, :edit, :list, :edit_toc, :update]

  def index
    list
  end

  def show
    @author = Person.find(params[:id])
    if @author.nil?
      flash[:error] = t(:no_such_item)
      redirect_to '/'
    else
      # TODO: add other types of content
      @count = {works: @author.work_ids.count}
    end

  end

  def edit
    @author = Person.find(params[:id])
    if @author.nil?
      flash[:error] = t(:no_such_item)
      redirect_to '/'
    else
      # do stuff
    end
  end

  def update
    @author = Person.find(params[:id])
    if @author.nil?
      flash[:error] = t(:no_such_item)
      redirect_to '/'
    else
      if @author.update_attributes(params[:author])
        format.html { redirect_to @author, notice: t(:updated_successfully) }
        format.json { head :ok }
      else
        format.html { render action: 'edit' }
        format.json { render json: @author.errors, status: :unprocessable_entity }
      end
    end
  end

  def list
    @authors = Person.page(params[:page]).order(params[:order]) # TODO: pagination
  end

  def toc
    @author = Person.find(params[:id])
    @tabclass = set_tab('authors')
    @print_url = url_for(action: :print, id: @author.id)
    markdown_toc = toc_links_to_markdown_links(@author.toc.toc)
    @html = MultiMarkdown.new(markdown_toc).to_html.force_encoding('UTF-8')
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
      unless params[:markdown].nil? # handle update payload
        if params[:old_timestamp].to_datetime != @author.toc.updated_at.to_datetime # check for update since form was issued
          # reject update, provide diff and fresh editbox
          @diff = Diffy::Diff.new(params[:markdown], @author.toc.toc)
          @rejected_update = params[:markdown]
        else
          t = @author.toc
          t.toc = params[:markdown]
          t.save!
        end
      end
      old_toc = @author.toc.toc
      @toc = @author.toc.refresh_links
      if @toc != old_toc # update the TOC if there have been HtmlFiles published since last time, regardless of whether or not further editing would be saved.
        @author.toc.toc = @toc
        @author.toc.save!
      end
      @toc_timestamp = @author.toc.updated_at
      markdown_toc = toc_links_to_markdown_links(@toc)
      @html = MultiMarkdown.new(markdown_toc).to_html.force_encoding('UTF-8')
    end
  end
end
