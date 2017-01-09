class ApiController < ApplicationController
  respond_to :json, :html
#  before_filter :ensure_json_request
  impressionist # log actions for pageview stats


  def ensure_json_request
    return if request.format == :json
    render :nothing => true, :status => 406
  end

  def query
    # TODO: add API key validation
    case params[:api_action]
    when 'get_markdown_by_path'
      the_url = params[:path]
      the_url = '/'+the_url if the_url[0] != '/' # prepend slash if necessary
      h = HtmlFile.find_by_url(the_url)
      unless h.nil?
        markdown = File.open(h.path+'.markdown').read
        puts "\n\nFILE FOUND, markdown size #{markdown.length}\n\n"
        respond_to do |fmt|
          fmt.html { render text: markdown }
          fmt.json { render json: { markdown: markdown }}
        end
      end
    when 'get_markdown'
      m = Manifestation.find(params[:mft])
      unless m.nil?
        respond_to do |fmt|
          fmt.html { render text: m.markdown }
          fmt.json { render json: { markdown: m.markdown }}
        end
      end
    when 'put_markdown'
      m = Manifestation.find(params[:mft])
      # TODO: add API key validation with WRITE access
      unless m.nil?
        m.markdown = params[:markdown]
        m.save!
        respond_to do |fmt|
          fmt.html { render text: 'OK' }
          fmt.json { render json: 'OK' }
        end
      else
        render :nothing => true, :status => 200
      end
    else
      render json: "ERROR: Unsupported API action #{params[:action]}"
    end
  end
end
