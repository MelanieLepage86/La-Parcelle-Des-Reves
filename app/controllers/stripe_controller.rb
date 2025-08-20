class StripeController < ApplicationController
  before_action :authenticate_user!

  def connect
    return redirect_to portail_artistes_path unless current_user

    account = Stripe::Account.create({
      type: 'express',
      country: 'FR',
      email: current_user.email,
      capabilities: { card_payments: {requested: true}, transfers: {requested: true} }
    })

    current_user.update!(stripe_account_id: account.id)

    link = Stripe::AccountLink.create({
      account: account.id,
      refresh_url: root_url,
      return_url: root_url,
      type: 'account_onboarding'
    })

    redirect_to link.url, allow_other_host: true
  end
end
