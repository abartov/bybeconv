class ApiController < ApplicationController
  respond_to :json
  before_filter :ensure_json_request  

  def ensure_json_request  
    return if request.format == :json
    render :nothing => true, :status => 406  
  end 

  def query
    # TODO: add API key validation
    case params[:api_action]
    when 'get_markdown'
      # TODO: replace this with serving from Expressions rather than HtmlFiles
      the_url = params[:path]
      the_url = '/'+the_url if the_url[0] != '/' # prepend slash if necessary
      h = HtmlFile.find_by_url(the_url)
      unless h.nil?
        markdown = File.open(h.path+'.markdown')
        render json: { markdown: markdown }
      end
    when 'put_markdown'
      # TODO: implement
      render :nothing => true, :status => 200
    else
      render json: "ERROR: Unsupported API action #{params[:action]}"
    end
  end
end
