# frozen_string_literal: true

class CollectionsMigrationController < ApplicationController
  before_action { |c| c.require_editor('edit_catalog') }

  def index
    @authorities = Authority.has_toc.order(impressions_count: :desc).limit(50)
  end

  def person
    @author = Authority.find(params[:id])
    @publications = @author.publications.no_volume.order(:title)
    @pub_options = @publications.map { |pub| [pub.title, pub.id] }
    @already_collected_ids = @author.collected_manifestation_ids
    # refresh uncollected works to reflect any changes we may have just made
    RefreshUncollectedWorksCollection.call(@author)
    prep_toc
    @top_nodes = GenerateTocTree.call(@author)

  end

  def create_collection
    au = Authority.find(params[:authority])
    if au.present?
      @collection = Collection.create!(title: params[:title], collection_type: params[:collection_type], publication_id: params[:publication_id])
      @collection.involved_authorities.create!(authority_id: au.id, role: params[:role])
      # associate specified manifestation IDs with the collection
      if params[:text_ids].present?
        ids = params[:text_ids].map(&:to_i)
        mm = Manifestation.where(id: ids)
        sorted_mm = mm.sort_by { |m| ids.index(m.id) }
        mm.each do |m|
          @collection.append_item(m)
        end
      end
    end
  end

  def migrate; end
end
