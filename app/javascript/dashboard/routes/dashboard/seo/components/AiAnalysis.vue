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

const aiAnalysis = computed(() => store.getters['seo/getAiAnalysis']);
const uiFlags = computed(() => store.getters['seo/getUIFlags']);
const isLoading = computed(() => uiFlags.value.isLoadingAi);

const handleAnalyze = async () => {
  if (!keyword.value.trim()) return;

  try {
    await store.dispatch('seo/fetchAiAnalysis', {
      keyword: keyword.value.trim(),
    });
  } catch (error) {
    console.error('AI analysis failed:', error);
  }
};
</script>

<template>
  <div class="ai-analysis">
    <!-- Search Form -->
    <div class="bg-n-solid-2 rounded-lg border border-n-weak p-6 mb-6">
      <form
        class="flex flex-col md:flex-row gap-4"
        @submit.prevent="handleAnalyze"
      >
        <div class="flex-1">
          <Input
            v-model="keyword"
            :label="t('SEO_TOOLS.AI.INPUT_LABEL')"
            :placeholder="t('SEO_TOOLS.AI.INPUT_PLACEHOLDER')"
            type="text"
            required
          />
        </div>
        <div class="flex items-end">
          <Button
            type="submit"
            icon="i-lucide-bot"
            :is-loading="isLoading"
            :disabled="isLoading || !keyword.trim()"
            :label="t('SEO_TOOLS.AI.ANALYZE')"
          />
        </div>
      </form>
    </div>

    <!-- Loading State -->
    <div
      v-if="isLoading"
      class="flex flex-col items-center justify-center py-12"
    >
      <Spinner size="large" />
      <span class="mt-3 text-n-slate-11">
        {{ t('SEO_TOOLS.AI.LOADING') }}
      </span>
      <p class="text-sm text-n-slate-10 mt-1">
        This may take a minute...
      </p>
    </div>

    <!-- Results -->
    <div v-else-if="aiAnalysis" class="space-y-6">
      <!-- AI Analysis Results -->
      <div
        v-if="aiAnalysis.ai_analysis"
        class="bg-n-solid-2 rounded-lg border border-n-weak p-6"
      >
        <div class="flex items-center gap-2 mb-4">
          <span class="i-lucide-bot size-5 text-n-blue-text" />
          <h3 class="text-lg font-semibold text-n-slate-12">
            {{ t('SEO_TOOLS.AI.RESULTS') }}
          </h3>
        </div>

        <div class="prose prose-sm max-w-none text-n-slate-12">
          <div
            v-if="typeof aiAnalysis.ai_analysis === 'object'"
            class="space-y-4"
          >
            <div
              v-if="aiAnalysis.ai_analysis.difficulty"
              class="p-4 bg-n-alpha-1 rounded-lg"
            >
              <h4 class="font-medium mb-2">Difficulty Assessment</h4>
              <p>{{ aiAnalysis.ai_analysis.difficulty }}</p>
            </div>

            <div
              v-if="aiAnalysis.ai_analysis.opportunities?.length"
              class="p-4 bg-n-alpha-1 rounded-lg"
            >
              <h4 class="font-medium mb-2">Opportunities</h4>
              <ul class="list-disc list-inside space-y-1">
                <li
                  v-for="(opp, i) in aiAnalysis.ai_analysis.opportunities"
                  :key="i"
                >
                  {{ opp }}
                </li>
              </ul>
            </div>

            <div
              v-if="aiAnalysis.ai_analysis.recommendations?.length"
              class="p-4 bg-n-alpha-1 rounded-lg"
            >
              <h4 class="font-medium mb-2">Recommendations</h4>
              <ul class="list-disc list-inside space-y-1">
                <li
                  v-for="(rec, i) in aiAnalysis.ai_analysis.recommendations"
                  :key="i"
                >
                  {{ rec }}
                </li>
              </ul>
            </div>

            <div
              v-if="aiAnalysis.ai_analysis.summary"
              class="p-4 bg-n-alpha-1 rounded-lg"
            >
              <h4 class="font-medium mb-2">Summary</h4>
              <p>{{ aiAnalysis.ai_analysis.summary }}</p>
            </div>
          </div>

          <pre
            v-else
            class="whitespace-pre-wrap bg-n-alpha-1 p-4 rounded-lg text-sm"
            >{{ JSON.stringify(aiAnalysis.ai_analysis, null, 2) }}</pre
          >
        </div>
      </div>

      <!-- Errors -->
      <div
        v-if="aiAnalysis.errors && Object.keys(aiAnalysis.errors).length"
        class="bg-n-ruby-3 rounded-lg border border-n-ruby-6 p-4"
      >
        <h4 class="font-medium text-n-ruby-11 mb-2">Errors</h4>
        <ul class="text-sm text-n-ruby-11 space-y-1">
          <li v-for="(err, key) in aiAnalysis.errors" :key="key">
            {{ key }}: {{ err }}
          </li>
        </ul>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else class="text-center py-12">
      <span class="i-lucide-bot size-12 text-n-slate-9 mx-auto block mb-4" />
      <p class="text-n-slate-11">
        {{ t('SEO_TOOLS.AI.EMPTY_STATE') }}
      </p>
    </div>
  </div>
</template>
