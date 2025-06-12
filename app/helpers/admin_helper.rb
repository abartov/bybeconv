module AdminHelper
  INTELLECTUAL_PROPERTIES_ID_TO_TEXT = Expression.intellectual_properties.to_h do |code, id|
    [id, I18n.t(code, scope: 'intellectual_property')]
  end

  def textify_intellectual_property_id(id)
    INTELLECTUAL_PROPERTIES_ID_TO_TEXT[id]
  end
end
