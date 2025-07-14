# frozen_string_literal: true

class CollectionsMailerPreview < ActionMailer::Preview
  def ordering_fixed
    CollectionsMailer.ordering_fixed({ 10 => 3, 11 => 1 })
  end
end
