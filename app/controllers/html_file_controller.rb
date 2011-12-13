class HtmlFileController < ApplicationController
  def analyze
    @text = HtmlFile.find(params[:id])
    @text.analyze
  end

  def analyze_all
    HtmlFile.find_all_by_status('Unknown').each { |h| h.analyze }
    redirect_to :action => :list
  end

  def list
    # calculate tallies
    @total_texts = HtmlFile.count
    @total_known = HtmlFile.count(:conditions => "status <> 'Unknown'")
    @total_images = HtmlFile.count(:conditions => "images = 't'")
    @total_footnotes = HtmlFile.count(:conditions => "footnotes = 't'")
    @total_tables = HtmlFile.count(:conditions => "tables = 't'")
    @texts = HtmlFile.page(params[:page]).order('status ASC')
  end

end
