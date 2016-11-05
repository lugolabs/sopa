class EmailsController < ApplicationController
  def index
  end

  def create

  end

  def hook
    Event.create({
      event_type:    params['event'],
      recipient:     params['recipient'],
      country:       params['country'],
      campaign_id:   params['campaign-id'],
      campaign_name: params['campaign-name']
    })
    head :ok
  end

  private

  def email_params
    params.permit(:email).require(:recipient, :subject, :text, :campaign_id)
  end
end
