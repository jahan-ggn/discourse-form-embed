import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import DButton from "discourse/ui-kit/d-button";
import DModal from "discourse/ui-kit/d-modal";
import { i18n } from "discourse-i18n";

export default class FormEmbedConsentModal extends Component {
  @tracked submitting = false;

  @action
  async confirm() {
    this.submitting = true;
    await this.args.model.onConfirm();
    this.args.closeModal();
  }

  @action
  cancel() {
    this.args.closeModal();
  }

  <template>
    <DModal
      @title={{i18n "form_embed.consent.title"}}
      @closeModal={{@closeModal}}
      class="form-embed-consent-modal"
    >
      <:body>
        <p>{{i18n "form_embed.consent.message"}}</p>
        <ul class="form-embed-consent-summary">
          {{#each @model.fields as |field|}}
            <li>
              <strong>{{field.label}}:</strong>
              {{field.value}}
            </li>
          {{/each}}
        </ul>
      </:body>
      <:footer>
        <DButton
          @label="form_embed.consent.confirm"
          @action={{this.confirm}}
          @disabled={{this.submitting}}
          class="btn-primary"
        />
        <DButton
          @label="form_embed.consent.cancel"
          @action={{this.cancel}}
          class="btn-flat"
        />
      </:footer>
    </DModal>
  </template>
}
