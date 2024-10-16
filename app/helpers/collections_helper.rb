module CollectionsHelper
  def url_for_collection_item(collitem)
    collitem.item.nil? ? nil : url_for(collitem.item)
  end
end
