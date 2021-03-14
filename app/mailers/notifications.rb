class Notifications < ActionMailer::Base
  default from: "editor@benyehuda.org" # TODO: un-hardcode

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.proof_fixed.subject
  #
  def proof_fixed(proof, url, m)
    @greeting = t(:hello_anon)
    @proof = proof
    @url = url
    unless m.nil?
      @url = 'https://benyehuda.org'+@url # TODO: un-hardcode
    end
    @m = m
    mail to: proof.from
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.proof_wontfix.subject
  #
  def proof_wontfix(proof, url, m, explanation)
    @greeting = t(:hello_anon)
    @proof = proof
    @url = url
    @explanation = explanation
    unless m.nil?
      @url = 'https://benyehuda.org'+@url # TODO: un-hardcode
    end
    @m = m
    mail to: proof.from
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.recommendation_accepted.subject
  #
  def recommendation_accepted(rec, url)
    @greeting = t(:hello_anon)
    @rec = rec
    @url = url

    mail to: rec.from
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.recommendation_published.subject
  #
  def recommendation_published(rec, html_url, blog_url)
    @greeting = t(:hello_anon)
    @published_url = blog_url
    @rec = rec
    @url = html_url
    mail to: rec.from
  end

  def contact_form_submitted(pp)
    @contact_form = {name: pp[:name], email: pp[:email], phone: pp[:phone], topic: pp[:topic] || pp[:rtopic], body: pp[:body]}
    mail to: 'editor@benyehuda.org', subject: t('notifications.contact_form_submitted.subject'), reply_to: pp[:email]
  end

  def volunteer_form_submitted(pp)
    @form = pp
    mail to: 'editor@benyehuda.org', subject: t('notifications.volunteer_form_submitted.subject'), reply_to: pp[:email]
  end
end
