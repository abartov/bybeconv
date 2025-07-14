# frozen_string_literal: true

# Base class for all application mailers
class ApplicationMailer < ActionMailer::Base
  abstract
  EDITOR_EMAIL = 'editor@benyehuda.org'

  default from: EDITOR_EMAIL
end
