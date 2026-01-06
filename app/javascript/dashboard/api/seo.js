import ApiClient from './ApiClient';

class SeoAPI extends ApiClient {
  constructor() {
    super('seo', { accountScoped: true });
  }

  keywordResearch(data) {
    return axios.post(`${this.url}/keyword_research`, data);
  }

  serpAnalysis(data) {
    return axios.post(`${this.url}/serp_analysis`, data);
  }

  aiAnalysis(data) {
    return axios.post(`${this.url}/ai_analysis`, data);
  }

  domainOverview(data) {
    return axios.post(`${this.url}/domain_overview`, data);
  }

  contentSuggestions(data) {
    return axios.post(`${this.url}/content_suggestions`, data);
  }
}

export default new SeoAPI();
