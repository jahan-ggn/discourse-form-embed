# frozen_string_literal: true

# name: discourse-form-embed
# about: Embed dynamic forms in posts using Discourse templates, submit to external endpoints
# version: 0.0.1
# authors: Jahan Gagan
# url: https://github.com/jahan-ggn/discourse-form-embed

enabled_site_setting :discourse_form_embed_enabled

module ::DiscourseFormEmbed
  PLUGIN_NAME = "discourse-form-embed"
end

require_relative "lib/discourse_form_embed/engine"
register_asset "stylesheets/form-template-chooser.scss"
register_asset "stylesheets/form-embed.scss"

after_initialize do
  # Code which should run after Rails has finished booting
end
