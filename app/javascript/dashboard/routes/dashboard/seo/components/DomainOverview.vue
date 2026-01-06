<script setup>
import { ref, computed } from 'vue';
import { useStore } from 'vuex';
import { useI18n } from 'vue-i18n';

import Button from 'dashboard/components-next/button/Button.vue';
import Input from 'dashboard/components-next/input/Input.vue';
import Spinner from 'shared/components/Spinner.vue';

const { t } = useI18n();
const store = useStore();

const domain = ref('');

const domainData = computed(() => store.getters['seo/getDomainData']);
const uiFlags = computed(() => store.getters['seo/getUIFlags']);
const isLoading = computed(() => uiFlags.value.isLoadingDomain);

const handleAnalyze = async () => {
  if (!domain.value.trim()) return;

  try {
    await store.dispatch('seo/fetchDomainOverview', {
      domain: domain.value.trim(),
    });
  } catch (error) {
    console.error('Domain analysis failed:', error);
  }
};

const formatNumber = num => {
  if (!num) return '0';
  if (num >= 1000000) return (num / 1000000).toFixed(1) + 'M';
  if (num >= 1000) return (num / 1000).toFixed(1) + 'K';
  return new Intl.NumberFormat().format(num);
};
</script>

<template>
  <div class="domain-overview">
    <!-- Search Form -->
    <div class="bg-n-solid-2 rounded-lg border border-n-weak p-6 mb-6">
      <form
        class="flex flex-col md:flex-row gap-4"
        @submit.prevent="handleAnalyze"
      >
        <div class="flex-1">
          <Input
            v-model="domain"
            :label="t('SEO_TOOLS.DOMAIN.INPUT_LABEL')"
            :placeholder="t('SEO_TOOLS.DOMAIN.INPUT_PLACEHOLDER')"
            type="text"
            required
          />
        </div>
        <div class="flex items-end">
          <Button
            type="submit"
            icon="i-lucide-globe"
            :is-loading="isLoading"
            :disabled="isLoading || !domain.trim()"
            :label="t('SEO_TOOLS.DOMAIN.ANALYZE')"
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
        {{ t('SEO_TOOLS.DOMAIN.LOADING') }}
      </span>
    </div>

    <!-- Results -->
    <div v-else-if="domainData" class="space-y-6">
      <div class="bg-n-solid-2 rounded-lg border border-n-weak p-6">
        <h3 class="text-lg font-semibold text-n-slate-12 mb-4">
          Domain: {{ domainData.domain }}
        </h3>

        <div
          v-if="domainData.data && domainData.data.length"
          class="space-y-6"
        >
          <div
            v-for="(item, index) in domainData.data"
            :key="index"
          >
            <!-- Metrics Grid -->
            <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
              <div class="bg-n-alpha-1 rounded-lg p-4">
                <p class="text-sm text-n-slate-11">Organic Traffic</p>
                <p class="text-2xl font-bold text-n-slate-12">
                  {{ formatNumber(item.metrics?.organic?.etv) }}
                </p>
              </div>
              <div class="bg-n-alpha-1 rounded-lg p-4">
                <p class="text-sm text-n-slate-11">Keywords</p>
                <p class="text-2xl font-bold text-n-slate-12">
                  {{ formatNumber(item.metrics?.organic?.count) }}
                </p>
              </div>
              <div class="bg-n-alpha-1 rounded-lg p-4">
                <p class="text-sm text-n-slate-11">Backlinks</p>
                <p class="text-2xl font-bold text-n-slate-12">
                  {{ formatNumber(item.metrics?.backlinks?.count) }}
                </p>
              </div>
              <div class="bg-n-alpha-1 rounded-lg p-4">
                <p class="text-sm text-n-slate-11">Referring Domains</p>
                <p class="text-2xl font-bold text-n-slate-12">
                  {{ formatNumber(item.metrics?.backlinks?.referring_domains) }}
                </p>
              </div>
            </div>

            <!-- Position Distribution -->
            <div
              v-if="item.metrics?.organic?.pos"
              class="bg-n-alpha-1 rounded-lg p-4"
            >
              <h4 class="font-medium text-n-slate-12 mb-3">
                Position Distribution
              </h4>
              <div class="grid grid-cols-5 gap-2">
                <div
                  v-for="(count, pos) in item.metrics.organic.pos"
                  :key="pos"
                  class="text-center"
                >
                  <p class="text-xs text-n-slate-11">{{ pos }}</p>
                  <p class="text-lg font-semibold text-n-slate-12">
                    {{ formatNumber(count) }}
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div v-else class="text-center py-8">
          <p class="text-n-slate-11">No data available for this domain</p>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else class="text-center py-12">
      <span class="i-lucide-globe size-12 text-n-slate-9 mx-auto block mb-4" />
      <p class="text-n-slate-11">
        {{ t('SEO_TOOLS.DOMAIN.EMPTY_STATE') }}
      </p>
    </div>
  </div>
</template>
