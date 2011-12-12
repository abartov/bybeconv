class HtmlFileController < ApplicationController
  def analyze
  end

  def analyze_all
  end

  def list
    @texts = HtmlFile.page(params[:page]).order('status ASC')
  end

end
