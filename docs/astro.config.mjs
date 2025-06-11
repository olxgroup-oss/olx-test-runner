// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
  ///TODO: Update page
  site: 'https://github.com/olxgroup-oss/test-runner',
  outDir: 'public',
  publicDir: 'static',
	integrations: [
		starlight({
			title: 'Test Runner',
			// social: [{ icon: 'github', label: 'GitHub', href: 'https://github.com/withastro/starlight' }],
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
