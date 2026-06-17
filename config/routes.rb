# frozen_string_literal: true

DiscourseFormEmbed::Engine.routes.draw do
  get "/examples" => "examples#index"
  # define routes here
end

Discourse::Application.routes.draw { mount ::DiscourseFormEmbed::Engine, at: "discourse-form-embed" }
