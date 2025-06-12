// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

export default defineConfig({
  site: 'https://olxgroup-oss.github.io',
  base: 'test-runner',
//   outDir: 'public',
//   publicDir: 'static',
	integrations: [
		starlight({
			title: 'Test Runner',
			sidebar: [
				{
					label: 'Guides',
					items: [
						{ label: 'Installation', slug: 'test-runner/guides/installation' },
						{ label: 'Generate command', slug: 'test-runner/guides/generate' },
						{ label: 'Test command', slug: 'test-runner/guides/test' },
						{ label: 'Validate command', slug: 'test-runner/guides/validate' },
						{ label: 'FAQ', slug: '/test-runner/guides/faq' },
					],
				},
			],
		}),
	],
});
