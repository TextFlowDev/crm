# frozen_string_literal: true

class Api::V1::Accounts::SeoController < Api::V1::Accounts::BaseController
  def keyword_research
    keyword = params[:keyword]
    location_code = params[:location_code] || 2458
    language_code = params[:language_code] || 'en'

    return render_error('Keyword is required', 400) if keyword.blank?

    service = Seo::DataForSeoService.new

    volume_result = service.keyword_research(keyword, location_code: location_code, language_code: language_code)
    suggestions_result = service.keyword_suggestions(keyword, location_code: location_code, language_code: language_code)

    render json: {
      keyword: keyword,
      search_volume: volume_result[:success] ? volume_result[:data] : nil,
      suggestions: suggestions_result[:success] ? suggestions_result[:data] : nil,
      errors: {
        volume: volume_result[:error],
        suggestions: suggestions_result[:error]
      }.compact
    }
  end

  def serp_analysis
    query = params[:query]

    return render_error('Query is required', 400) if query.blank?

    service = Seo::SerperService.new
    result = service.search(query, {
                              country: params[:country] || 'my',
                              language: params[:language] || 'en',
                              num: params[:num] || 10
                            })

    if result[:success]
      render json: {
        query: query,
        organic: result[:data]['organic'] || [],
        related_searches: result[:data]['relatedSearches'] || [],
        people_also_ask: result[:data]['peopleAlsoAsk'] || [],
        knowledge_graph: result[:data]['knowledgeGraph'],
        search_parameters: result[:data]['searchParameters']
      }
    else
      render_error(result[:error], 500)
    end
  end

  def ai_analysis
    keyword = params[:keyword]

    return render_error('Keyword is required', 400) if keyword.blank?

    serper = Seo::SerperService.new
    serp_result = serper.search(keyword)

    dataforseo = Seo::DataForSeoService.new
    keyword_result = dataforseo.keyword_research(keyword)

    n8n = Seo::N8nWebhookService.new
    ai_result = n8n.analyze_keyword(
      keyword,
      serp_result[:success] ? serp_result[:data] : nil,
      keyword_result[:success] ? keyword_result[:data] : nil
    )

    render json: {
      keyword: keyword,
      serp_data: serp_result[:success] ? serp_result[:data] : nil,
      keyword_data: keyword_result[:success] ? keyword_result[:data] : nil,
      ai_analysis: ai_result[:success] ? ai_result[:data] : nil,
      errors: {
        serp: serp_result[:error],
        keyword: keyword_result[:error],
        ai: ai_result[:error]
      }.compact
    }
  end

  def domain_overview
    domain = params[:domain]

    return render_error('Domain is required', 400) if domain.blank?

    cleaned_domain = domain.gsub(%r{^https?://}, '').gsub(/^www\./, '').gsub(%r{/$}, '')

    service = Seo::DataForSeoService.new
    result = service.domain_overview(cleaned_domain)

    if result[:success]
      render json: {
        domain: cleaned_domain,
        data: result[:data]
      }
    else
      render_error(result[:error], 500)
    end
  end

  def content_suggestions
    keyword = params[:keyword]

    return render_error('Keyword is required', 400) if keyword.blank?

    serper = Seo::SerperService.new
    serp_result = serper.search(keyword, num: 5)

    competitors = if serp_result[:success]
                    serp_result[:data]['organic']&.map { |r| { title: r['title'], link: r['link'], snippet: r['snippet'] } } || []
                  else
                    []
                  end

    n8n = Seo::N8nWebhookService.new
    result = n8n.generate_content_suggestions(keyword, competitors)

    render json: {
      keyword: keyword,
      competitors: competitors,
      suggestions: result[:success] ? result[:data] : nil,
      error: result[:error]
    }
  end

  private

  def render_error(message, status)
    render json: { error: message }, status: status
  end
end
