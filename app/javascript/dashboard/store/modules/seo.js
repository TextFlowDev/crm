import types from '../mutation-types';
import SeoAPI from '../../api/seo';

const state = {
  keywordData: null,
  serpData: null,
  aiAnalysis: null,
  domainData: null,
  contentSuggestions: null,
  uiFlags: {
    isLoadingKeyword: false,
    isLoadingSerp: false,
    isLoadingAi: false,
    isLoadingDomain: false,
    isLoadingContent: false,
  },
  searchHistory: [],
};

const getters = {
  getKeywordData: $state => $state.keywordData,
  getSerpData: $state => $state.serpData,
  getAiAnalysis: $state => $state.aiAnalysis,
  getDomainData: $state => $state.domainData,
  getContentSuggestions: $state => $state.contentSuggestions,
  getUIFlags: $state => $state.uiFlags,
  getSearchHistory: $state => $state.searchHistory,
};

const actions = {
  async fetchKeywordResearch({ commit }, { keyword, locationCode, languageCode }) {
    commit(types.SET_SEO_UI_FLAG, { isLoadingKeyword: true });
    try {
      const response = await SeoAPI.keywordResearch({
        keyword,
        location_code: locationCode,
        language_code: languageCode,
      });
      commit(types.SET_SEO_KEYWORD_DATA, response.data);
      commit(types.ADD_SEO_SEARCH_HISTORY, {
        type: 'keyword',
        query: keyword,
        timestamp: new Date(),
      });
      return response.data;
    } catch (error) {
      throw error;
    } finally {
      commit(types.SET_SEO_UI_FLAG, { isLoadingKeyword: false });
    }
  },

  async fetchSerpAnalysis({ commit }, { query, country, language, num }) {
    commit(types.SET_SEO_UI_FLAG, { isLoadingSerp: true });
    try {
      const response = await SeoAPI.serpAnalysis({
        query,
        country,
        language,
        num,
      });
      commit(types.SET_SEO_SERP_DATA, response.data);
      commit(types.ADD_SEO_SEARCH_HISTORY, {
        type: 'serp',
        query,
        timestamp: new Date(),
      });
      return response.data;
    } catch (error) {
      throw error;
    } finally {
      commit(types.SET_SEO_UI_FLAG, { isLoadingSerp: false });
    }
  },

  async fetchAiAnalysis({ commit }, { keyword }) {
    commit(types.SET_SEO_UI_FLAG, { isLoadingAi: true });
    try {
      const response = await SeoAPI.aiAnalysis({ keyword });
      commit(types.SET_SEO_AI_ANALYSIS, response.data);
      return response.data;
    } catch (error) {
      throw error;
    } finally {
      commit(types.SET_SEO_UI_FLAG, { isLoadingAi: false });
    }
  },

  async fetchDomainOverview({ commit }, { domain }) {
    commit(types.SET_SEO_UI_FLAG, { isLoadingDomain: true });
    try {
      const response = await SeoAPI.domainOverview({ domain });
      commit(types.SET_SEO_DOMAIN_DATA, response.data);
      commit(types.ADD_SEO_SEARCH_HISTORY, {
        type: 'domain',
        query: domain,
        timestamp: new Date(),
      });
      return response.data;
    } catch (error) {
      throw error;
    } finally {
      commit(types.SET_SEO_UI_FLAG, { isLoadingDomain: false });
    }
  },

  async fetchContentSuggestions({ commit }, { keyword }) {
    commit(types.SET_SEO_UI_FLAG, { isLoadingContent: true });
    try {
      const response = await SeoAPI.contentSuggestions({ keyword });
      commit(types.SET_SEO_CONTENT_SUGGESTIONS, response.data);
      return response.data;
    } catch (error) {
      throw error;
    } finally {
      commit(types.SET_SEO_UI_FLAG, { isLoadingContent: false });
    }
  },

  clearSeoData({ commit }) {
    commit(types.CLEAR_SEO_DATA);
  },
};

const mutations = {
  [types.SET_SEO_KEYWORD_DATA]($state, data) {
    $state.keywordData = data;
  },
  [types.SET_SEO_SERP_DATA]($state, data) {
    $state.serpData = data;
  },
  [types.SET_SEO_AI_ANALYSIS]($state, data) {
    $state.aiAnalysis = data;
  },
  [types.SET_SEO_DOMAIN_DATA]($state, data) {
    $state.domainData = data;
  },
  [types.SET_SEO_CONTENT_SUGGESTIONS]($state, data) {
    $state.contentSuggestions = data;
  },
  [types.SET_SEO_UI_FLAG]($state, flags) {
    $state.uiFlags = { ...$state.uiFlags, ...flags };
  },
  [types.ADD_SEO_SEARCH_HISTORY]($state, entry) {
    $state.searchHistory = [entry, ...$state.searchHistory.slice(0, 19)];
  },
  [types.CLEAR_SEO_DATA]($state) {
    $state.keywordData = null;
    $state.serpData = null;
    $state.aiAnalysis = null;
    $state.domainData = null;
    $state.contentSuggestions = null;
  },
};

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations,
};
