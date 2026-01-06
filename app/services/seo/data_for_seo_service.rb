# frozen_string_literal: true

class Seo::DataForSeoService
  include HTTParty
  base_uri 'https://api.dataforseo.com/v3'

  def initialize
    @login = ENV.fetch('DATAFORSEO_LOGIN', nil)
    @password = ENV.fetch('DATAFORSEO_PASSWORD', nil)
  end

  def keyword_research(keyword, location_code: 2458, language_code: 'en')
    endpoint = '/keywords_data/google_ads/search_volume/live'

    payload = [
      {
        keywords: [keyword],
        location_code: location_code,
        language_code: language_code,
        date_from: 3.months.ago.strftime('%Y-%m-%d'),
        date_to: Date.today.strftime('%Y-%m-%d'),
        include_adult_keywords: false
      }
    ]

    make_request(endpoint, payload)
  end

  def keyword_suggestions(seed_keyword, location_code: 2458, language_code: 'en', limit: 50)
    endpoint = '/keywords_data/google_ads/keywords_for_keywords/live'

    payload = [
      {
        keywords: [seed_keyword],
        location_code: location_code,
        language_code: language_code,
        limit: limit,
        include_adult_keywords: false,
        sort_by: 'search_volume'
      }
    ]

    make_request(endpoint, payload)
  end

  def keyword_difficulty(keywords, location_code: 2458, language_code: 'en')
    endpoint = '/dataforseo_labs/google/bulk_keyword_difficulty/live'

    payload = [
      {
        keywords: Array(keywords).take(1000),
        location_code: location_code,
        language_code: language_code
      }
    ]

    make_request(endpoint, payload)
  end

  def domain_overview(domain, location_code: 2458, language_code: 'en')
    endpoint = '/dataforseo_labs/google/domain_rank_overview/live'

    payload = [
      {
        target: domain,
        location_code: location_code,
        language_code: language_code
      }
    ]

    make_request(endpoint, payload)
  end

  private

  def make_request(endpoint, payload)
    return { success: false, error: 'DataForSEO credentials not configured' } if @login.blank? || @password.blank?

    response = self.class.post(
      endpoint,
      basic_auth: { username: @login, password: @password },
      headers: { 'Content-Type' => 'application/json' },
      body: payload.to_json,
      timeout: 60
    )

    parsed = JSON.parse(response.body)

    if parsed['status_code'] == 20_000
      { success: true, data: parsed['tasks']&.first&.dig('result') || [] }
    else
      { success: false, error: parsed['status_message'], code: parsed['status_code'] }
    end
  rescue StandardError => e
    Rails.logger.error("DataForSEO Error: #{e.message}")
    { success: false, error: e.message }
  end
end
