# frozen_string_literal: true

class Seo::SerperService
  include HTTParty
  base_uri 'https://google.serper.dev'

  def initialize
    @api_key = ENV.fetch('SERPER_API_KEY', nil)
  end

  def search(query, options = {})
    endpoint = '/search'

    payload = {
      q: query,
      gl: options[:country] || 'my',
      hl: options[:language] || 'en',
      num: options[:num] || 10,
      autocorrect: options[:autocorrect] || true
    }

    make_request(endpoint, payload)
  end

  def news(query, options = {})
    endpoint = '/news'

    payload = {
      q: query,
      gl: options[:country] || 'my',
      hl: options[:language] || 'en',
      num: options[:num] || 10
    }

    make_request(endpoint, payload)
  end

  def images(query, options = {})
    endpoint = '/images'

    payload = {
      q: query,
      gl: options[:country] || 'my',
      hl: options[:language] || 'en',
      num: options[:num] || 10
    }

    make_request(endpoint, payload)
  end

  private

  def make_request(endpoint, payload)
    return { success: false, error: 'Serper API key not configured' } if @api_key.blank?

    response = self.class.post(
      endpoint,
      headers: {
        'X-API-KEY' => @api_key,
        'Content-Type' => 'application/json'
      },
      body: payload.to_json,
      timeout: 30
    )

    parsed = JSON.parse(response.body)

    if response.success?
      { success: true, data: parsed }
    else
      { success: false, error: parsed['message'] || 'Unknown error' }
    end
  rescue StandardError => e
    Rails.logger.error("Serper Error: #{e.message}")
    { success: false, error: e.message }
  end
end
