// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

export default defineConfig({
  site: 'https://olxgroup-oss.github.io',
  base: 'olx-test-runner',
//   outDir: 'public',
//   publicDir: 'static',
	integrations: [
		starlight({
			title: 'OLX Test Runner',
			sidebar: [
				{
					label: 'Guides',
					items: [
						{ label: 'Installation', slug: 'guides/installation' },
						{ label: 'Generate command', slug: 'guides/generate' },
						{ label: 'Test command', slug: 'guides/test' },
						{ label: 'Validate command', slug: 'guides/validate' },
						{ label: 'FAQ', slug: 'guides/faq' },
					],
				},
			],
		}),
	],
});
