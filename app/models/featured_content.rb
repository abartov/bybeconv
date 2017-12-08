class FeaturedContent < ActiveRecord::Base
  belongs_to :manifestation
  belongs_to :person
  belongs_to :user

  attr_accessible :title, :body, :external_link
  has_many :featured_content_features, class_name: 'FeaturedContentFeature'

  def featured_list
    s = ''
    featured_content_features.each{ |fcf|
      s += '<br/>'+fcf.fromdate.strftime("%d-%m-%Y")+' '+I18n.t(:until)+' '+fcf.todate.strftime('%d-%m-%Y')
    }
    return s[5..-1] || ''
  end

end
