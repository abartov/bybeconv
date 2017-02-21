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
      if @author.update_attributes(params[:person])
        flash[:notice] = I18n.t(:updated_successfully)
        show
        render action: :show, id: @author.id
      else
        format.html { render action: 'edit' }
        format.json { render json: @author.errors, status: :unprocessable_entity }
      end
    end
  end

  def list
    def_order = 'metadata_approved asc, name asc'
    @people = Person.page(params[:page]).order(params[:order].nil? ? def_order : params[:order]) # TODO: pagination
  end

  def toc
    @author = Person.find(params[:id])
    # temporary protection against null ToCs while we're migrating
    unless @author.toc.nil?
      @tabclass = set_tab('authors')
      @print_url = url_for(action: :print, id: @author.id)
      @toc = @author.toc.refresh_links
      markdown_toc = toc_links_to_markdown_links(@toc)
      @html = MultiMarkdown.new(markdown_toc).to_html.force_encoding('UTF-8')
      @pagetype = :author
      @entity = @author
      @page_title = "#{@author.name} - #{t(:table_of_contents)}"
      impressionist(@author) # log actions for pageview stats
    else
      flash[:error] = I18n.t(:no_toc_yet)
      redirect_to '/'
    end
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
