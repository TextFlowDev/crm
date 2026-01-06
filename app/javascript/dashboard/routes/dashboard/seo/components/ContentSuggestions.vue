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

const contentData = computed(() => store.getters['seo/getContentSuggestions']);
const uiFlags = computed(() => store.getters['seo/getUIFlags']);
const isLoading = computed(() => uiFlags.value.isLoadingContent);

const handleGenerate = async () => {
  if (!keyword.value.trim()) return;

  try {
    await store.dispatch('seo/fetchContentSuggestions', {
      keyword: keyword.value.trim(),
    });
  } catch (error) {
    console.error('Content suggestions failed:', error);
  }
};
</script>

<template>
  <div class="content-suggestions">
    <!-- Search Form -->
    <div class="bg-n-solid-2 rounded-lg border border-n-weak p-6 mb-6">
      <form
        class="flex flex-col md:flex-row gap-4"
        @submit.prevent="handleGenerate"
      >
        <div class="flex-1">
          <Input
            v-model="keyword"
            :label="t('SEO_TOOLS.CONTENT.INPUT_LABEL')"
            :placeholder="t('SEO_TOOLS.CONTENT.INPUT_PLACEHOLDER')"
            type="text"
            required
          />
        </div>
        <div class="flex items-end">
          <Button
            type="submit"
            icon="i-lucide-lightbulb"
            :is-loading="isLoading"
            :disabled="isLoading || !keyword.trim()"
            :label="t('SEO_TOOLS.CONTENT.GENERATE')"
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
        {{ t('SEO_TOOLS.CONTENT.LOADING') }}
      </span>
    </div>

    <!-- Results -->
    <div v-else-if="contentData" class="space-y-6">
      <!-- Competitors -->
      <div
        v-if="contentData.competitors?.length"
        class="bg-n-solid-2 rounded-lg border border-n-weak p-6"
      >
        <h3 class="text-lg font-semibold text-n-slate-12 mb-4">
          Top Competitors for "{{ contentData.keyword }}"
        </h3>

        <div class="space-y-3">
          <div
            v-for="(competitor, index) in contentData.competitors"
            :key="index"
            class="p-4 bg-n-alpha-1 rounded-lg"
          >
            <div class="flex items-start justify-between gap-4">
              <div class="flex-1 min-w-0">
                <a
                  :href="competitor.link"
                  target="_blank"
                  rel="noopener noreferrer"
                  class="text-n-blue-text hover:underline font-medium block truncate"
                >
                  {{ competitor.title }}
                </a>
                <p class="text-sm text-n-slate-11 mt-1">
                  {{ competitor.snippet }}
                </p>
              </div>
              <a
                :href="competitor.link"
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

      <!-- AI Suggestions -->
      <div
        v-if="contentData.suggestions"
        class="bg-n-solid-2 rounded-lg border border-n-weak p-6"
      >
        <div class="flex items-center gap-2 mb-4">
          <span class="i-lucide-lightbulb size-5 text-n-amber-text" />
          <h3 class="text-lg font-semibold text-n-slate-12">
            Content Suggestions
          </h3>
        </div>

        <div class="prose prose-sm max-w-none text-n-slate-12">
          <div
            v-if="typeof contentData.suggestions === 'object'"
            class="space-y-4"
          >
            <div
              v-if="contentData.suggestions.content_ideas?.length"
              class="p-4 bg-n-alpha-1 rounded-lg"
            >
              <h4 class="font-medium mb-2">Content Ideas</h4>
              <ul class="list-disc list-inside space-y-1">
                <li
                  v-for="(idea, i) in contentData.suggestions.content_ideas"
                  :key="i"
                >
                  {{ idea }}
                </li>
              </ul>
            </div>

            <div
              v-if="contentData.suggestions.headlines?.length"
              class="p-4 bg-n-alpha-1 rounded-lg"
            >
              <h4 class="font-medium mb-2">Headline Suggestions</h4>
              <ul class="list-disc list-inside space-y-1">
                <li
                  v-for="(headline, i) in contentData.suggestions.headlines"
                  :key="i"
                >
                  {{ headline }}
                </li>
              </ul>
            </div>

            <div
              v-if="contentData.suggestions.outline"
              class="p-4 bg-n-alpha-1 rounded-lg"
            >
              <h4 class="font-medium mb-2">Content Outline</h4>
              <div class="whitespace-pre-wrap">
                {{ contentData.suggestions.outline }}
              </div>
            </div>
          </div>

          <pre
            v-else
            class="whitespace-pre-wrap bg-n-alpha-1 p-4 rounded-lg text-sm"
            >{{ JSON.stringify(contentData.suggestions, null, 2) }}</pre
          >
        </div>
      </div>

      <!-- Error -->
      <div
        v-if="contentData.error"
        class="bg-n-ruby-3 rounded-lg border border-n-ruby-6 p-4"
      >
        <p class="text-n-ruby-11">{{ contentData.error }}</p>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else class="text-center py-12">
      <span
        class="i-lucide-file-text size-12 text-n-slate-9 mx-auto block mb-4"
      />
      <p class="text-n-slate-11">
        {{ t('SEO_TOOLS.CONTENT.EMPTY_STATE') }}
      </p>
    </div>
  </div>
</template>
