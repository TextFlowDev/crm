<script setup>
import { ref, computed } from 'vue';
import { useStore } from 'vuex';
import { useI18n } from 'vue-i18n';

import Button from 'dashboard/components-next/button/Button.vue';
import Input from 'dashboard/components-next/input/Input.vue';
import Spinner from 'shared/components/Spinner.vue';

const { t } = useI18n();
const store = useStore();

const keyword = ref('');
const locationCode = ref('2458');

const locations = [
  { value: '2458', label: 'Malaysia' },
  { value: '2840', label: 'United States' },
  { value: '2826', label: 'United Kingdom' },
  { value: '2702', label: 'Singapore' },
  { value: '2360', label: 'Indonesia' },
];

const keywordData = computed(() => store.getters['seo/getKeywordData']);
const uiFlags = computed(() => store.getters['seo/getUIFlags']);
const isLoading = computed(() => uiFlags.value.isLoadingKeyword);

const searchVolume = computed(() => {
  return keywordData.value?.search_volume?.[0]?.search_volume || 0;
});

const cpc = computed(() => {
  return keywordData.value?.search_volume?.[0]?.cpc?.toFixed(2) || '0.00';
});

const competition = computed(() => {
  const comp = keywordData.value?.search_volume?.[0]?.competition;
  if (!comp) return 'N/A';
  if (comp < 0.33) return 'Low';
  if (comp < 0.66) return 'Medium';
  return 'High';
});

const suggestions = computed(() => {
  return keywordData.value?.suggestions || [];
});

const handleSearch = async () => {
  if (!keyword.value.trim()) return;

  try {
    await store.dispatch('seo/fetchKeywordResearch', {
      keyword: keyword.value.trim(),
      locationCode: parseInt(locationCode.value, 10),
      languageCode: 'en',
    });
  } catch (error) {
    console.error('Keyword research failed:', error);
  }
};

const searchKeyword = kw => {
  keyword.value = kw;
  handleSearch();
};

const formatNumber = num => {
  if (!num) return '0';
  return new Intl.NumberFormat().format(num);
};
</script>

<template>
  <div class="keyword-research">
    <!-- Search Form -->
    <div class="bg-n-solid-2 rounded-lg border border-n-weak p-6 mb-6">
      <form
        class="flex flex-col md:flex-row gap-4"
        @submit.prevent="handleSearch"
      >
        <div class="flex-1">
          <Input
            v-model="keyword"
            :label="t('SEO_TOOLS.KEYWORD.INPUT_LABEL')"
            :placeholder="t('SEO_TOOLS.KEYWORD.INPUT_PLACEHOLDER')"
            type="text"
            required
          />
        </div>
        <div class="w-full md:w-48">
          <label
            class="block text-sm font-medium text-n-slate-12 mb-1"
          >
            {{ t('SEO_TOOLS.KEYWORD.LOCATION') }}
          </label>
          <select
            v-model="locationCode"
            class="w-full px-4 py-2 border border-n-weak rounded-lg focus:ring-2 focus:ring-n-blue-text focus:border-transparent bg-n-alpha-1 text-n-slate-12"
          >
            <option
              v-for="loc in locations"
              :key="loc.value"
              :value="loc.value"
            >
              {{ loc.label }}
            </option>
          </select>
        </div>
        <div class="flex items-end">
          <Button
            type="submit"
            icon="i-lucide-search"
            :is-loading="isLoading"
            :disabled="isLoading || !keyword.trim()"
            :label="t('SEO_TOOLS.KEYWORD.SEARCH')"
          />
        </div>
      </form>
    </div>

    <!-- Loading State -->
    <div
      v-if="isLoading"
      class="flex items-center justify-center py-12"
    >
      <Spinner size="large" />
      <span class="ml-3 text-n-slate-11">
        {{ t('SEO_TOOLS.KEYWORD.LOADING') }}
      </span>
    </div>

    <!-- Results -->
    <div v-else-if="keywordData" class="space-y-6">
      <!-- Search Volume Card -->
      <div
        class="bg-n-solid-2 rounded-lg border border-n-weak p-6"
      >
        <h3 class="text-lg font-semibold text-n-slate-12 mb-4">
          {{ t('SEO_TOOLS.KEYWORD.METRICS') }}: "{{ keywordData.keyword }}"
        </h3>

        <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
          <div class="bg-n-alpha-1 rounded-lg p-4">
            <p class="text-sm text-n-slate-11">
              {{ t('SEO_TOOLS.KEYWORD.VOLUME') }}
            </p>
            <p class="text-2xl font-bold text-n-slate-12">
              {{ formatNumber(searchVolume) }}
            </p>
          </div>
          <div class="bg-n-alpha-1 rounded-lg p-4">
            <p class="text-sm text-n-slate-11">
              {{ t('SEO_TOOLS.KEYWORD.CPC') }}
            </p>
            <p class="text-2xl font-bold text-n-slate-12">${{ cpc }}</p>
          </div>
          <div class="bg-n-alpha-1 rounded-lg p-4">
            <p class="text-sm text-n-slate-11">
              {{ t('SEO_TOOLS.KEYWORD.COMPETITION') }}
            </p>
            <p class="text-2xl font-bold text-n-slate-12">
              {{ competition }}
            </p>
          </div>
          <div class="bg-n-alpha-1 rounded-lg p-4">
            <p class="text-sm text-n-slate-11">
              {{ t('SEO_TOOLS.KEYWORD.TREND') }}
            </p>
            <div class="flex items-center">
              <span class="i-lucide-trending-up size-5 text-n-teal-text" />
              <span class="ml-1 font-semibold text-n-teal-text">Stable</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Keyword Suggestions -->
      <div
        v-if="suggestions.length"
        class="bg-n-solid-2 rounded-lg border border-n-weak p-6"
      >
        <h3 class="text-lg font-semibold text-n-slate-12 mb-4">
          {{ t('SEO_TOOLS.KEYWORD.SUGGESTIONS') }}
        </h3>

        <div class="overflow-x-auto">
          <table class="w-full">
            <thead>
              <tr class="border-b border-n-weak">
                <th
                  class="text-left py-3 px-4 text-sm font-medium text-n-slate-11"
                >
                  {{ t('SEO_TOOLS.KEYWORD.TABLE.KEYWORD') }}
                </th>
                <th
                  class="text-right py-3 px-4 text-sm font-medium text-n-slate-11"
                >
                  {{ t('SEO_TOOLS.KEYWORD.TABLE.VOLUME') }}
                </th>
                <th
                  class="text-right py-3 px-4 text-sm font-medium text-n-slate-11"
                >
                  {{ t('SEO_TOOLS.KEYWORD.TABLE.CPC') }}
                </th>
                <th
                  class="text-right py-3 px-4 text-sm font-medium text-n-slate-11"
                >
                  {{ t('SEO_TOOLS.KEYWORD.TABLE.COMPETITION') }}
                </th>
                <th
                  class="text-center py-3 px-4 text-sm font-medium text-n-slate-11"
                >
                  {{ t('SEO_TOOLS.KEYWORD.TABLE.ACTIONS') }}
                </th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="(suggestion, index) in suggestions.slice(0, 20)"
                :key="index"
                class="border-b border-n-weak/50 hover:bg-n-alpha-1"
              >
                <td class="py-3 px-4 text-sm text-n-slate-12">
                  {{ suggestion.keyword }}
                </td>
                <td class="py-3 px-4 text-sm text-n-slate-11 text-right">
                  {{ formatNumber(suggestion.search_volume) }}
                </td>
                <td class="py-3 px-4 text-sm text-n-slate-11 text-right">
                  ${{ suggestion.cpc?.toFixed(2) || '0.00' }}
                </td>
                <td class="py-3 px-4 text-sm text-n-slate-11 text-right">
                  {{ ((suggestion.competition || 0) * 100).toFixed(0) }}%
                </td>
                <td class="py-3 px-4 text-center">
                  <button
                    class="text-n-blue-text hover:text-n-blue-text/80"
                    :title="t('SEO_TOOLS.KEYWORD.SEARCH_THIS')"
                    @click="searchKeyword(suggestion.keyword)"
                  >
                    <span class="i-lucide-search size-4" />
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else class="text-center py-12">
      <span class="i-lucide-search size-12 text-n-slate-9 mx-auto block mb-4" />
      <p class="text-n-slate-11">
        {{ t('SEO_TOOLS.KEYWORD.EMPTY_STATE') }}
      </p>
    </div>
  </div>
</template>
