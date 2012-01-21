class HtmlFileController < ApplicationController
  def analyze
    @text = HtmlFile.find(params[:id])
    @text.analyze
  end

  def analyze_all
    HtmlFile.analyze_all
    redirect_to :action => :list
  end

  def list
    # calculate tallies
    @total_texts = HtmlFile.count
    @total_known = HtmlFile.count(:conditions => "status <> 'Unknown'")
    @total_images = HtmlFile.count(:conditions => "images = 't'")
    @total_footnotes = HtmlFile.count(:conditions => "footnotes = 't'")
    @total_tables = HtmlFile.count(:conditions => "tables = 't'")
    @total_badenc = HtmlFile.count(:conditions => "status = 'BadCP1255'")
    @total_fileerr = HtmlFile.count(:conditions => "status = 'FileError'")
    @total_parsed = HtmlFile.count(:conditions => "status = 'Parsed'")
    @total_accepted = HtmlFile.count(:conditions => "status = 'Accepted'")
    @texts = HtmlFile.page(params[:page]).order('status ASC')
  end
  def parse
    @text = HtmlFile.find(params[:id])
    @text.parse
  end
  def render_html
    @text = HtmlFile.find(params[:id])
    @markdown = File.open(@text.path+'.markdown', 'r:UTF-8').read
    @html = MultiMarkdown.new(@markdown).to_html.force_encoding('UTF-8') # TODO: figure out why to_html defaults to ASCII 8-bit
  end
end
