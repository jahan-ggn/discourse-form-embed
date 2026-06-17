# frozen_string_literal: true

# name: discourse-form-embed
# about: TODO
# meta_topic_id: TODO
# version: 0.0.1
# authors: Discourse
# url: TODO
# required_version: 2.7.0

enabled_site_setting :discourse_form_embed_enabled

module ::DiscourseFormEmbed
  PLUGIN_NAME = "discourse-form-embed"
end

require_relative "lib/discourse_form_embed/engine"

after_initialize do
  # Code which should run after Rails has finished booting
end
