require 'minitest/autorun'
# require_relative 'emailer'

class Emailer::ConfigurationTest < Minitest::Test
  # Can set correct configuration
  def test_is_set_correctly
    api_key = '111'
    domain  = 'example.com'

    Emailer.configure do |config|
      config.api_key = api_key
      config.domain  = domain
    end

    assert_equal api_key, Emailer.configuration.api_key
    assert_equal domain, Emailer.configuration.domain
    assert_equal 'https://api:111@api.mailgun.net/v3/example.com',  Emailer.configuration.base_url
  end
end

class Emailer::MessageTest < Minitest::Test
  def setup
    @api_key = '111'
    @domain  = 'example.com'

    # Store params in a Hash for verifying mock calls
    @params = {
      'from'       => 'Postmaster <postmaster@example.com>',
      'to'         => 'Artan <artan@lugolabs.com>',
      'subject'    => 'Hello',
      'text'       => 'Just saying hello',
      'o:campaign' => 'MyFirstCampaign'
    }
  end

  def test_message_success_delivery
    Emailer.configure do |config|
      config.api_key = @api_key
      config.domain  = @domain
    end

    # Mock a REST client that interacts over HTTP with Mailgun API
    rest_client = Minitest::Mock.new
    rest_client.expect(:call, 'OK', [Emailer::Message::PATH, @params])

    # Create the message
    recipient = Emailer::Address.new(@params['to'])
    message   = Emailer::Message.new(recipient, @params['subject'], @params['text'], @params['o:campaign'])

    # Stub the HTTP post
    Emailer::Client.stub :post, rest_client do
      response = message.deliver
      assert_equal 'OK', response
    end

    # Verify REST client
    rest_client.verify
  end

  def test_message_error_delivery
    # Should use validations instead, rescuing everything at the moment for brevity
    # Create the message
    recipient = Emailer::Address.new(@params['to'])
    message   = Emailer::Message.new(recipient, @params['subject'], @params['text'], @params['o:campaign'])

    # Stub the HTTP post
    Emailer::Client.stub :post, 'Error' do
      response = message.deliver
      assert_equal 'Error', response
    end
  end
end

class Emailer::AddressTest < Minitest::Test
  def setup
    @email_address = 'mike@example.com'

    # Create the recipient
    @recipient = Emailer::Address.new(@email_address)

    # Mock a REST client that interacts over HTTP with Mailgun API
    @rest_client = Minitest::Mock.new
  end

  def test_suppressed
    # Mock calls to all suppression types
    Emailer::Address::SUPPRESSION_TYPES.each_with_index do |suppression_type, i|
      return_value = i == 1 ? nil : 'OK'
      @rest_client.expect(:call, return_value, ["/#{suppression_type}/#{@email_address}"])
    end

    # Stub client
    Emailer::Client.stub :get, @rest_client do
      suppressions = @recipient.suppressed?
      assert_equal({"bounces"=>"OK", "complaints"=>"OK"}, suppressions)
    end

    # Verify REST client
    @rest_client.verify
  end

  def test_messages
    params = {
      recipient: @email_address
    }

    # Mock a REST client that interacts over HTTP with Mailgun API
    @rest_client.expect(:call, 'OK', [Emailer::Address::EVENTS_PATH, params])

    # Stub client
    Emailer::Client.stub :get, @rest_client do
      assert_equal 'OK', @recipient.messages
    end

    # Verify REST client
    @rest_client.verify
  end
end



