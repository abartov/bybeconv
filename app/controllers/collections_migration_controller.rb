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
    @nonce = 'top'
  end

  def create_collection
    au = Authority.find(params[:authority])
    if au.present?
      title = params[:pub_title].present? ? params[:pub_title] : params[:title]
      @collection = Collection.create!(title: title.strip, collection_type: params[:collection_type], publication_id: params[:publication_id], publisher_line: params[:guessed_publisher], pub_year: params[:guessed_year])
      @collection.involved_authorities.create!(authority_id: au.id, role: params[:role])
      # associate specified manifestation IDs with the collection
      if params[:text_ids].present?
        params[:text_ids].each do |id|
          if id =~ /\D/ # placeholder text
            @collection.append_collection_item(CollectionItem.new(alt_title: id))
          else
            m = Manifestation.find(id)
            @collection.append_item(m)
          end
        end
      end
    end
  end

  def migrate
    @author = Authority.find(params[:id])
    @author.legacy_credits = migrate_credits(@author.toc.credit_section)
    @author.legacy_toc_id = @author.toc_id # deliberately not destroying the legacy Toc entity for now
    @author.toc_id = nil
    @author.save!
    redirect_to collections_migration_index_path, notice: t('.migrated_html', link: authority_url(@author))
  end

  protected

  def migrate_credits(buf)
    return '' if buf.blank?
    credits = []
    buf.split("\n").each do |line|
      next if line.blank?
      next if line =~ /הקלידו/ || line =~ /הקלידה/ || line =~ /הקליד/ || line =~ /הגיהו/ || line =~ /horizontal/ || line =~ /##/

      credits << line.sub(/^\*\s+/, '').strip
    end
    credits.uniq.sort.join("\n")
  end
end
