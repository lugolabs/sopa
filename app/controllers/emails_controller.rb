class EmailsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :hook

  def index
    @email = Email.new
  end

  def create
    @message = ''
    @email   = Email.new(email_params)
    if @email.save
      @message = 'Email sent successfully'
      @email   = Email.new
    end
  end

  def hook
    Event.create({
      event_type:    params['event'],
      recipient:     params['recipient'],
      country:       params['country'],
      campaign_id:   params['campaign-id'],
      campaign_name: params['campaign-name']
    })
    render json: { "message": "Post received. Thanks!" }
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
