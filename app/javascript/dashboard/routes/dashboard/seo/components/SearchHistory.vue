<script setup>
import { computed } from 'vue';
import { useStore } from 'vuex';
import { useI18n } from 'vue-i18n';

const emit = defineEmits(['select']);

const { t } = useI18n();
const store = useStore();

const searchHistory = computed(() => store.getters['seo/getSearchHistory']);

const getTypeIcon = type => {
  switch (type) {
    case 'keyword':
      return 'i-lucide-key';
    case 'serp':
      return 'i-lucide-list';
    case 'domain':
      return 'i-lucide-globe';
    default:
      return 'i-lucide-search';
  }
};

const getTypeColor = type => {
  switch (type) {
    case 'keyword':
      return 'text-n-blue-text';
    case 'serp':
      return 'text-n-teal-text';
    case 'domain':
      return 'text-n-amber-text';
    default:
      return 'text-n-slate-11';
  }
};

const formatTime = timestamp => {
  const date = new Date(timestamp);
  const now = new Date();
  const diff = now - date;

  if (diff < 60000) return 'Just now';
  if (diff < 3600000) return `${Math.floor(diff / 60000)}m ago`;
  if (diff < 86400000) return `${Math.floor(diff / 3600000)}h ago`;
  return date.toLocaleDateString();
};

const handleSelect = item => {
  emit('select', item);
};
</script>

<template>
  <div class="search-history p-4">
    <h3 class="text-sm font-semibold text-n-slate-12 mb-4">
      {{ t('SEO_TOOLS.HISTORY.TITLE') }}
    </h3>

    <div v-if="searchHistory.length" class="space-y-2">
      <button
        v-for="(item, index) in searchHistory"
        :key="index"
        class="w-full text-left p-3 rounded-lg hover:bg-n-alpha-1 transition-colors group"
        @click="handleSelect(item)"
      >
        <div class="flex items-center gap-2">
          <span
            :class="[getTypeIcon(item.type), 'size-4', getTypeColor(item.type)]"
          />
          <span class="flex-1 text-sm text-n-slate-12 truncate">
            {{ item.query }}
          </span>
        </div>
        <p class="text-xs text-n-slate-10 mt-1 pl-6">
          {{ formatTime(item.timestamp) }}
        </p>
      </button>
    </div>

    <div v-else class="text-center py-8">
      <span class="i-lucide-history size-8 text-n-slate-9 mx-auto block mb-2" />
      <p class="text-sm text-n-slate-11">
        {{ t('SEO_TOOLS.HISTORY.EMPTY') }}
      </p>
    </div>
  </div>
</template>
