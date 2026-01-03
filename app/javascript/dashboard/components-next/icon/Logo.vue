<script setup>
import { useAttrs, computed } from 'vue';
import { useMapGetter } from 'dashboard/composables/store';

const attrs = useAttrs();
const globalConfig = useMapGetter('globalConfig/get');

// Ahmad AI: Use custom logo
const logoUrl = computed(() => {
  return globalConfig.value?.logoThumbnail || '/brand-assets/logo.png';
});
</script>

<template>
  <img
    v-bind="attrs"
    :src="logoUrl"
    alt="Ahmad AI"
  />
</template>
