require 'net/http'
require 'rest-client'

module Emailer
  class << self
    # Configuration for mailgun credentials
    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration.new
      yield configuration
    end
  end

  class Configuration
    attr_accessor :api_key, :domain

    def base_url
      @base_url ||= "https://api:#{api_key}@api.mailgun.net/v3/#{domain}"
    end
  end

  # Simple proxy to HTTP methods fetching the api.
  # It separates remote fetching from email logic.
  # It does use base_url from configuration as it is
  # an Emailer client after all
  class Client
    # @param [String] path appended to base url to communicate
    # with Mailgun API
    # @param [Hash] to be sent to Mailgun API
    def self.get(path, params = {})
      RestClient.get(url(path), params)
    rescue RestClient::ResourceNotFound
    end

    # @param [String] path appended to base url to communicate
    # with Mailgun API
    # @param [Hash] to be sent to Mailgun API
    def self.post(path, params = {})
      RestClient.post(url(path), params)
    end

    private

    def self.url(path)
      "#{Emailer.configuration.base_url}#{path}"
    end
  end

  class Message
    # Default sender
    FROM = 'Postmaster <postmaster@example.com>'
    PATH = '/messages'

    attr_accessor :recipient, :subject, :text, :campaign_id

    # @param [Address] recipient of the message
    # @param [String] subject of the message
    # @param [String] text of the message
    # @param [String] campain_id to include with the message
    def initialize(recipient, subject, text, campaign_id)
      @recipient   = recipient
      @subject     = subject
      @text        = text
      @campaign_id = campaign_id
    end

    # Delivers the message to Mailgun
    # @return [String] response from client
    def deliver
      response = ''
      begin
        response = Client.post(PATH, params)
      # rescue => e
        # response = "An error occurred with message: #{e.message}"
      end
      response
    end

    private

    def params
      @params ||= {
        'from'       => FROM,
        'to'         => @recipient.email_address,
        'subject'    => @subject,
        'text'       => @text,
        'o:campaign' => @campaign_id
      }
    end
  end

  # A wrapper object around an email address, intelligent
  # enough to check itself if it's supressed or any
  # previous messages
  class Address
    SUPPRESSION_TYPES = %w(bounces unsubscribes complaints)
    EVENTS_PATH       = '/events'

    attr_accessor :email_address

    # @param [String] email_address stores email address
    def initialize(email_address)
      @email_address = email_address
    end

    # Fetch all suppression APIs from Mailgun
    # @return [Hash] with responses keyed by suppression type
    def suppressed?
      suppressions = {}
      SUPPRESSION_TYPES.each do |suppression_type|
        if response = fetch_surpressed(suppression_type)
          suppressions[suppression_type] = response
        end
      end
      suppressions
    end

    # Fetches all previous messages from Mailgun Events API
    # @return [String] JSON string with response without parsing
    def messages
      Client.get(EVENTS_PATH, {
        recipient: @email_address
      })
    end

    private

    def fetch_surpressed(suppression_type)
      Client.get("/#{suppression_type}/#{@email_address}")
    end
  end
end
