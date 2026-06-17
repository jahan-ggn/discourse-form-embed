# Discourse Form Embed Plugin

**Plugin Summary**

Embed dynamic forms in Discourse posts using existing form templates. Submissions are proxied to external endpoints with authenticated user identity.

## Features

- Insert forms via composer toolbar: `[form=1]`
- Reuses Discourse admin form templates
- Group-based access control
- Backend proxy to external endpoints with API key auth
- Submission confirmation modal

## Setup

1. Enable plugin in site settings
2. Create form templates in `/admin/customize/form-templates`
3. Map form IDs to endpoints in `discourse_form_embed_endpoints` (format: `1|https://...`)
4. Set `discourse_form_embed_api_key` for endpoint verification
5. Assign allowed groups

## License

MIT
