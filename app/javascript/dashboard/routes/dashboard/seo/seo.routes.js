import { frontendURL } from '../../../helper/URLHelper';

const SeoIndex = () => import('./Index.vue');

export const routes = [
  {
    path: frontendURL('accounts/:accountId/seo'),
    name: 'seo_tools',
    component: SeoIndex,
    meta: {
      permissions: ['administrator', 'agent'],
    },
  },
];
