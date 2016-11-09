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
end
