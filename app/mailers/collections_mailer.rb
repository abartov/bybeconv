# frozen_string_literal: true

# Mailer for email notifications related to Collections
class CollectionsMailer < ApplicationMailer
  # Email sent by collection ordering fix rake task
  # @param errors Hash where key is a collection_id and value is a number of fixed ordering collisions
  def ordering_fixed(collection_errors_count)
    @collection_errors_count = collection_errors_count
    mail to: EDITOR_EMAIL, subject: t('.subject')
  end
end
