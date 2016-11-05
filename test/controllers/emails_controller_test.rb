require 'test_helper'

class EmailsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get emails_url
    assert_response :success
  end

  test "hook creates new event" do
    params = {
      'event'         => 'opened',
      'recipient'     => 'hello@example.com',
      'country'       => 'UK',
      'campaign-id'   => 'CAMPAIGN_11',
      'campaign-name' => 'CAMPAIGN_11_NAME'
    }

    # Check new event created
    assert_difference('Event.count', 1) do
      get hook_emails_url, params: params
    end

    # Check last event created info
    event = Event.last
    assert_equal params['event'],         event.event_type
    assert_equal params['recipient'],     event.recipient
    assert_equal params['country'],       event.country
    assert_equal params['campaign-id'],   event.campaign_id
    assert_equal params['campaign-name'], event.campaign_name
  end
end
