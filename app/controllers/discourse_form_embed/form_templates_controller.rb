# frozen_string_literal: true

module ::DiscourseFormEmbed
  class FormTemplatesController < ApplicationController
    requires_plugin PLUGIN_NAME
    requires_login

    def show
      params.require(:id)

      template = FormTemplate.find_by(id: params[:id])
      raise Discourse::NotFound if template.nil?

      parsed = YAML.safe_load(template.template, permitted_classes: [Date, Time])
      render json: { form_template: { id: template.id, name: template.name, fields: parsed } }
    end
  end
end
