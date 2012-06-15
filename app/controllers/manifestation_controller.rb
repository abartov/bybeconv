class ManifestationController < ApplicationController
  def show
  end

  def render
    @m = Manifestation.find(params[:id])
    @html = MultiMarkdown.new(@m.markdown).to_html.force_encoding('UTF-8')
  end

  def edit
  end

end
