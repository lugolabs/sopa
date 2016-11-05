class EmailsController < ApplicationController
  def index
    @email = Email.new
  end

  def create
    @email = Email.new(email_params)
    @message = @email.save ? 'Email sent successfully' : ''
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

  def opened
    @events = Event.where(event_type: 'opened').order(id: :desc)
  end

  def clicked
    @events = Event.where(event_type: 'clicked').order(id: :desc)
  end

  private

  def email_params
    params.require(:email).permit(:recipient, :subject, :body, :campaign_id)
  end
end
