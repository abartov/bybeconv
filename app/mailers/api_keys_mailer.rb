# frozen_string_literal: true

# Mailer to send emails about API keys
class ApiKeysMailer < ApplicationMailer
  # Email sent to email specified in new Api Key request upon creation
  def key_created(api_key)
    @api_key = api_key
    mail to: api_key.email, subject: t('api_keys_mailer.key_created.subject')
  end

  # Email sent to editor when somebody creates a new API Key
  def key_created_to_editor(api_key)
    @api_key = api_key
    mail to: EDITOR_EMAIL, subject: t('api_keys_mailer.key_created_to_editor.subject')
  end
end
