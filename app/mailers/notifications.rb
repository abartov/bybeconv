class Notifications < ActionMailer::Base
  default from: "editor@benyehuda.org"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.proof_fixed.subject
  #
  def proof_fixed(proof, url)
    @greeting = t(:hello_x, {:name => user.name})
    @proof = proof
    @url = url
    mail to: proof.from
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.proof_wontfix.subject
  #
  def proof_wontfix(proof, url)
    @greeting = t(:hello_x, {:name => user.name})
    @proof = proof
    @url = url
    mail to: proof.from
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.recommendation_accepted.subject
  #
  def recommendation_accepted(rec, url)
    @greeting = t(:hello_x, {:name => user.name})
    @rec = rec
    @url = url

    mail to: proof.from
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.recommendation_blogged.subject
  #
  def recommendation_blogged(rec, html_url, blog_url)
    @greeting = t(:hello_x, {:name => user.name})
    @blog_url = blog_url
    @rec = rec
    @url = html_url
    mail to: proof.from
  end
end
