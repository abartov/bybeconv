class UserBlocksController < ApplicationController
  before_action :set_user_block, only: %i(show edit update destroy)

  # GET /user_blocks or /user_blocks.json
  def index
    @user_blocks = UserBlock.all
  end

  # GET /user_blocks/1 or /user_blocks/1.json
  def show
  end

  # GET /user_blocks/new
  def new
    @user_block = UserBlock.new
  end

  # GET /user_blocks/1/edit
  def edit
  end

  # POST /user_blocks or /user_blocks.json
  def create
    @user_block = UserBlock.new(user_block_params)

    respond_to do |format|
      if @user_block.save
        format.html { redirect_to user_block_url(@user_block), notice: 'User block was successfully created.' }
        format.json { render :show, status: :created, location: @user_block }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @user_block.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /user_blocks/1 or /user_blocks/1.json
  def update
    respond_to do |format|
      if @user_block.update(user_block_params)
        format.html { redirect_to user_block_url(@user_block), notice: 'User block was successfully updated.' }
        format.json { render :show, status: :ok, location: @user_block }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @user_block.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /user_blocks/1 or /user_blocks/1.json
  def destroy
    @user_block.destroy

    respond_to do |format|
      format.html { redirect_to user_blocks_url, notice: 'User block was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user_block
    @user_block = UserBlock.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def user_block_params
    params.require(:user_block).permit(:user_id, :context, :expires_at, :blocker_id, :reason)
  end
end
