class AboutnessesController < ApplicationController
  before_filter :require_editor

  def create
    @ab = Aboutness.new(work_id: params['work_id'], user_id: params['suggested_by'])
    #byebug
    case params['aboutness_type']
    when 'Person'
      @ab.aboutable_type = 'Person'
      @ab.aboutable_id = params['add_person_topic']
    when 'Work'
      @ab.aboutable_type = 'Work'
      m = Manifestation.find(params['add_work_topic'])
      unless m.nil?
        w = m.expressions[0].works[0] # TODO: generalize?
        @ab.aboutable_id = w.id
      end
    when 'Wikidata'
      @ab.wikidata_qid = params['add_external_topic'][1..-1].to_i
      @ab.wikidata_label = params['wikidata_label']
    end
    @ab.save!
  end

  def remove
    ab = Aboutness.find(params[:id])
    if ab.nil?
      flash[:error] = t(:no_such_item)
    else
      ab.destroy!
      flash[:notice] = t(:deleted_successfully)
    end
    redirect_to url_for(controller: :manifestation, action: :show, id: params[:manifestation_id])
  end
end
