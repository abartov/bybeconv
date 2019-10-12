class AnthologiesController < ApplicationController
  before_action :set_anthology, only: [:show, :edit, :update, :destroy]

  # GET /anthologies
  def index
    @anthologies = Anthology.all
  end

  # GET /anthologies/1
  def show
    if @anthology.accessible?
      @htmls = []
      @anthology.ordered_texts.each {|text|
        @htmls << [text.title, text.render_html]
      }
    else
      redirect_to '/', error: t(:no_permission)
    end
  end

  # GET /anthologies/new
  def new
    @anthology = Anthology.new
  end

  # GET /anthologies/1/edit
  def edit
  end

  # POST /anthologies
  def create
    @anthology = Anthology.new(anthology_params)

    if @anthology.save
      redirect_to @anthology, notice: 'Anthology was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /anthologies/1
  def update
    if @anthology.update(anthology_params)
      redirect_to @anthology, notice: 'Anthology was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /anthologies/1
  def destroy
    @anthology.destroy
    redirect_to anthologies_url, notice: 'Anthology was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_anthology
      @anthology = Anthology.find(params[:id])
    end

    def anthology_params
      params.require(:anthology).permit(:title, :access, :sequence)
    end
end
