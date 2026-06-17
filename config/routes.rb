# frozen_string_literal: true

DiscourseFormEmbed::Engine.routes.draw do
  get "/template/:id" => "form_templates#show"
  post "/submit" => "submissions#create"
end

Discourse::Application.routes.draw do
  mount ::DiscourseFormEmbed::Engine, at: "discourse-form-embed"
end
