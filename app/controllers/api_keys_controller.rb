class ApiKeysController < ApplicationController
  before_action :require_admin, except: %i(new create)

  before_action :set_model, only: %i(edit update destroy)

  # GET /api_keys
  # GET /api_keys.json
  def index
    @api_keys = ApiKey.all
  end

  # GET /api_keys/new
  # GET /api_keys/new.json
  def new
    @api_key = ApiKey.new
  end

  # POST /api_keys
  # POST /api_keys.json
  def create
    @api_key = ApiKey.new(key_params)
    @api_key.status = :enabled
    @api_key.key = SecureRandom.hex(32)

    # Extremely simple antispam protection
    unless params['ziburit'] =~ /ביאליק/
      flash.now.alert = 'Antispam protection failed'
      render action: 'new', status: :unprocessable_content
      return
    end

    if @api_key.save
      begin
        ApiKeysMailer.key_created_to_editor(@api_key).deliver
        ApiKeysMailer.key_created(@api_key).deliver
      rescue StandardError => e
        # TODO: add error notification via service like Rollbar
      end

      redirect_to '/', notice: 'Api key was successfully created, check email for details'
    else
      render action: 'new', status: :unprocessable_content
    end
  end

  # PUT /api_keys/1
  # PUT /api_keys/1.json
  def update
    if @api_key.update(key_params)
      redirect_to api_keys_path, notice: 'Api key was successfully updated.'
    else
      render action: 'edit', status: :unprocessable_content
    end
  end

  # DELETE /api_keys/1
  # DELETE /api_keys/1.json
  def destroy
    @api_key.destroy!
    redirect_to api_keys_url
  end

  private

  def key_params
    params[:api_key].permit(:id, :description, :email, :status)
  end

  def set_model
    @api_key = ApiKey.find(params[:id])
  end
end
