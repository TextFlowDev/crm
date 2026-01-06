# frozen_string_literal: true

class Seo::N8nWebhookService
  include HTTParty

  def initialize
    @webhook_url = ENV.fetch('N8N_SEO_WEBHOOK_URL', nil)
  end

  def analyze_keyword(keyword, serp_data, keyword_data)
    return { success: false, error: 'n8n webhook URL not configured' } if @webhook_url.blank?

    payload = {
      action: 'analyze_keyword',
      keyword: keyword,
      serp_results: serp_data,
      keyword_metrics: keyword_data,
      timestamp: Time.current.iso8601
    }

    make_webhook_request(payload)
  end

  def generate_content_suggestions(keyword, competitors)
    return { success: false, error: 'n8n webhook URL not configured' } if @webhook_url.blank?

    payload = {
      action: 'content_suggestions',
      keyword: keyword,
      competitors: competitors,
      timestamp: Time.current.iso8601
    }

    make_webhook_request(payload)
  end

  def seo_audit(url)
    return { success: false, error: 'n8n webhook URL not configured' } if @webhook_url.blank?

    payload = {
      action: 'seo_audit',
      url: url,
      timestamp: Time.current.iso8601
    }

    make_webhook_request(payload)
  end

  private

  def make_webhook_request(payload)
    response = self.class.post(
      @webhook_url,
      headers: { 'Content-Type' => 'application/json' },
      body: payload.to_json,
      timeout: 120
    )

    if response.success?
      { success: true, data: JSON.parse(response.body) }
    else
      { success: false, error: 'Webhook request failed', status: response.code }
    end
  rescue StandardError => e
    Rails.logger.error("n8n Webhook Error: #{e.message}")
    { success: false, error: e.message }
  end
end
