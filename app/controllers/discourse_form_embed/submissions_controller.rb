# frozen_string_literal: true
module ::DiscourseFormEmbed
  class SubmissionsController < ApplicationController
    requires_plugin PLUGIN_NAME
    requires_login
    before_action :ensure_plugin_enabled

    def create
      params.require(:form_id)
      params.require(:data)

      form_id = params[:form_id]
      endpoints_setting = SiteSetting.discourse_form_embed_endpoints.to_s

      endpoint = nil
      endpoints_setting
        .split("|")
        .each_slice(2) do |id, url|
          next if id.blank? || url.blank?
          if id.strip == form_id
            endpoint = url.strip
            break
          end
        end

      if endpoint.blank?
        raise Discourse::InvalidParameters.new("No endpoint configured for this form")
      end

      payload = {
        username: current_user.username,
        discourse_user_id: current_user.id,
        form_id: form_id,
        form_name: params[:form_name],
        data: params[:data],
        submitted_at: Time.now.utc.iso8601,
      }

      begin
        uri = URI.parse(endpoint)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == "https"
        http.open_timeout = 5
        http.read_timeout = 10

        request = Net::HTTP::Post.new(uri.request_uri)
        request["Content-Type"] = "application/json"
        request["Authorization"] = "Bearer #{SiteSetting.discourse_form_embed_api_key}"
        request.body = payload.to_json

        response = http.request(request)

        if response.is_a?(Net::HTTPSuccess)
          render json: { success: true }
        else
          Rails.logger.warn("Form embed submission failed: #{response.code} #{response.body}")
          render json: {
                   success: false,
                   error: "External service returned #{response.code}",
                 },
                 status: :bad_gateway
        end
      rescue => e
        Rails.logger.error("Form embed submission error: #{e.message}")
        render json: {
                 success: false,
                 error: "Failed to reach external endpoint",
               },
               status: :bad_gateway
      end
    end

    private

    def ensure_plugin_enabled
      raise Discourse::NotFound unless SiteSetting.discourse_form_embed_enabled
    end
  end
end
