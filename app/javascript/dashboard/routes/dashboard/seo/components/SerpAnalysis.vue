<script setup>
import { ref, computed } from 'vue';
import { useStore } from 'vuex';
import { useI18n } from 'vue-i18n';

import Button from 'dashboard/components-next/button/Button.vue';
import Input from 'dashboard/components-next/input/Input.vue';
import Spinner from 'shared/components/Spinner.vue';

const { t } = useI18n();
const store = useStore();

const query = ref('');

const serpData = computed(() => store.getters['seo/getSerpData']);
const uiFlags = computed(() => store.getters['seo/getUIFlags']);
const isLoading = computed(() => uiFlags.value.isLoadingSerp);

const organicResults = computed(() => serpData.value?.organic || []);
const relatedSearches = computed(() => serpData.value?.related_searches || []);
const peopleAlsoAsk = computed(() => serpData.value?.people_also_ask || []);

const handleSearch = async () => {
  if (!query.value.trim()) return;

  try {
    await store.dispatch('seo/fetchSerpAnalysis', {
      query: query.value.trim(),
      country: 'my',
      language: 'en',
      num: 10,
    });
  } catch (error) {
    console.error('SERP analysis failed:', error);
  }
};
</script>

<template>
  <div class="serp-analysis">
    <!-- Search Form -->
    <div class="bg-n-solid-2 rounded-lg border border-n-weak p-6 mb-6">
      <form
        class="flex flex-col md:flex-row gap-4"
        @submit.prevent="handleSearch"
      >
        <div class="flex-1">
          <Input
            v-model="query"
            :label="t('SEO_TOOLS.SERP.INPUT_LABEL')"
            :placeholder="t('SEO_TOOLS.SERP.INPUT_PLACEHOLDER')"
            type="text"
            required
          />
        </div>
        <div class="flex items-end">
          <Button
            type="submit"
            icon="i-lucide-search"
            :is-loading="isLoading"
            :disabled="isLoading || !query.trim()"
            :label="t('SEO_TOOLS.SERP.SEARCH')"
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
        {{ t('SEO_TOOLS.SERP.LOADING') }}
      </span>
    </div>

    <!-- Results -->
    <div v-else-if="serpData" class="space-y-6">
      <!-- Organic Results -->
      <div class="bg-n-solid-2 rounded-lg border border-n-weak p-6">
        <h3 class="text-lg font-semibold text-n-slate-12 mb-4">
          {{ t('SEO_TOOLS.SERP.RESULTS') }} ({{ organicResults.length }})
        </h3>

        <div class="space-y-4">
          <div
            v-for="(result, index) in organicResults"
            :key="index"
            class="p-4 bg-n-alpha-1 rounded-lg"
          >
            <div class="flex items-start justify-between gap-4">
              <div class="flex-1 min-w-0">
                <div class="flex items-center gap-2 mb-1">
                  <span
                    class="flex-shrink-0 w-6 h-6 flex items-center justify-center bg-n-blue-text/10 text-n-blue-text text-xs font-bold rounded"
                  >
                    {{ index + 1 }}
                  </span>
                  <a
                    :href="result.link"
                    target="_blank"
                    rel="noopener noreferrer"
                    class="text-n-blue-text hover:underline font-medium truncate"
                  >
                    {{ result.title }}
                  </a>
                </div>
                <p class="text-xs text-n-slate-10 truncate mb-2">
                  {{ result.link }}
                </p>
                <p class="text-sm text-n-slate-11">
                  {{ result.snippet }}
                </p>
              </div>
              <a
                :href="result.link"
                target="_blank"
                rel="noopener noreferrer"
                class="flex-shrink-0 text-n-slate-11 hover:text-n-slate-12"
              >
                <span class="i-lucide-external-link size-4" />
              </a>
            </div>
          </div>
        </div>
      </div>

      <!-- People Also Ask -->
      <div
        v-if="peopleAlsoAsk.length"
        class="bg-n-solid-2 rounded-lg border border-n-weak p-6"
      >
        <h3 class="text-lg font-semibold text-n-slate-12 mb-4">
          {{ t('SEO_TOOLS.SERP.PAA') }}
        </h3>

        <div class="space-y-2">
          <div
            v-for="(paa, index) in peopleAlsoAsk"
            :key="index"
            class="p-3 bg-n-alpha-1 rounded-lg"
          >
            <p class="text-sm font-medium text-n-slate-12">
              {{ paa.question }}
            </p>
            <p v-if="paa.snippet" class="text-sm text-n-slate-11 mt-1">
              {{ paa.snippet }}
            </p>
          </div>
        </div>
      </div>

      <!-- Related Searches -->
      <div
        v-if="relatedSearches.length"
        class="bg-n-solid-2 rounded-lg border border-n-weak p-6"
      >
        <h3 class="text-lg font-semibold text-n-slate-12 mb-4">
          {{ t('SEO_TOOLS.SERP.RELATED') }}
        </h3>

        <div class="flex flex-wrap gap-2">
          <button
            v-for="(related, index) in relatedSearches"
            :key="index"
            class="px-3 py-1.5 bg-n-alpha-1 hover:bg-n-alpha-2 rounded-full text-sm text-n-slate-12 transition-colors"
            @click="
              query = related.query;
              handleSearch();
            "
          >
            {{ related.query }}
          </button>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else class="text-center py-12">
      <span class="i-lucide-list size-12 text-n-slate-9 mx-auto block mb-4" />
      <p class="text-n-slate-11">
        {{ t('SEO_TOOLS.SERP.EMPTY_STATE') }}
      </p>
    </div>
  </div>
</template>
