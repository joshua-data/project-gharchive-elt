export default {
	kit: {
		// Rename SvelteKit's app dir from the default `_app` to `app` so the
		// leading underscore doesn't trigger Jekyll's auto-exclude on the
		// consuming GitHub Pages site (joshua-data.github.io).
		appDir: 'app'
	}
};
