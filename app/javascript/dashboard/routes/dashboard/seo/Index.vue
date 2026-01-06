<script setup>
import { ref, computed } from 'vue';
import { useStore } from 'vuex';
import { useI18n } from 'vue-i18n';

import Button from 'dashboard/components-next/button/Button.vue';
import KeywordResearch from './components/KeywordResearch.vue';
import SerpAnalysis from './components/SerpAnalysis.vue';
import AiAnalysis from './components/AiAnalysis.vue';
import DomainOverview from './components/DomainOverview.vue';
import ContentSuggestions from './components/ContentSuggestions.vue';
import SearchHistory from './components/SearchHistory.vue';

const { t } = useI18n();
const store = useStore();

const activeTab = ref('keyword');

const tabs = [
  { key: 'keyword', label: 'SEO_TOOLS.TABS.KEYWORD', icon: 'i-lucide-key' },
  { key: 'serp', label: 'SEO_TOOLS.TABS.SERP', icon: 'i-lucide-list' },
  { key: 'ai', label: 'SEO_TOOLS.TABS.AI', icon: 'i-lucide-bot' },
  { key: 'domain', label: 'SEO_TOOLS.TABS.DOMAIN', icon: 'i-lucide-globe' },
  { key: 'content', label: 'SEO_TOOLS.TABS.CONTENT', icon: 'i-lucide-file-text' },
];

const clearAllData = () => {
  store.dispatch('seo/clearSeoData');
};

const handleHistorySelect = item => {
  if (item.type === 'keyword') {
    activeTab.value = 'keyword';
  } else if (item.type === 'serp') {
    activeTab.value = 'serp';
  } else if (item.type === 'domain') {
    activeTab.value = 'domain';
  }
};
</script>

<template>
  <div class="flex flex-col h-full bg-n-background">
    <!-- Header -->
    <header
      class="flex items-center justify-between px-6 py-4 border-b border-n-weak bg-n-solid-2"
    >
      <div class="flex items-center gap-3">
        <span class="i-lucide-search-check size-6 text-n-blue-text" />
        <div>
          <h1 class="text-xl font-semibold text-n-slate-12">
            {{ t('SEO_TOOLS.TITLE') }}
          </h1>
          <p class="text-sm text-n-slate-11">
            {{ t('SEO_TOOLS.DESCRIPTION') }}
          </p>
        </div>
      </div>
      <div class="flex items-center gap-2">
        <Button
          icon="i-lucide-rotate-ccw"
          color="slate"
          variant="faded"
          size="sm"
          :label="t('SEO_TOOLS.CLEAR')"
          @click="clearAllData"
        />
      </div>
    </header>

    <!-- Main Content -->
    <div class="flex flex-1 overflow-hidden">
      <!-- Sidebar - Search History -->
      <aside
        class="w-64 border-r border-n-weak bg-n-solid-2 overflow-y-auto hidden lg:block"
      >
        <SearchHistory @select="handleHistorySelect" />
      </aside>

      <!-- Main Panel -->
      <main class="flex-1 overflow-y-auto">
        <!-- Tabs -->
        <div
          class="sticky top-0 z-10 bg-n-solid-2 border-b border-n-weak"
        >
          <nav class="flex px-6 gap-1">
            <button
              v-for="tab in tabs"
              :key="tab.key"
              :class="[
                'px-4 py-3 text-sm font-medium border-b-2 transition-colors flex items-center gap-2',
                activeTab === tab.key
                  ? 'border-n-blue-text text-n-blue-text'
                  : 'border-transparent text-n-slate-11 hover:text-n-slate-12',
              ]"
              @click="activeTab = tab.key"
            >
              <span :class="[tab.icon, 'size-4']" />
              {{ t(tab.label) }}
            </button>
          </nav>
        </div>

        <!-- Tab Content -->
        <div class="p-6">
          <KeywordResearch v-if="activeTab === 'keyword'" />
          <SerpAnalysis v-else-if="activeTab === 'serp'" />
          <AiAnalysis v-else-if="activeTab === 'ai'" />
          <DomainOverview v-else-if="activeTab === 'domain'" />
          <ContentSuggestions v-else-if="activeTab === 'content'" />
        </div>
      </main>
    </div>
  </div>
</template>
