import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import DButton from "discourse/ui-kit/d-button";
import DModal from "discourse/ui-kit/d-modal";
import { i18n } from "discourse-i18n";

export default class FormTemplateChooserModal extends Component {
  @tracked formTemplates = [];
  @tracked loading = true;

  constructor() {
    super(...arguments);
    this.loadFormTemplates();
  }

  async loadFormTemplates() {
    try {
      const result = await ajax("/form-templates.json");
      this.formTemplates = result.form_templates || [];
    } catch (error) {
      popupAjaxError(error);
    } finally {
      this.loading = false;
    }
  }

  @action
  selectTemplate(template) {
    this.args.model.toolbarEvent.addText(`[form=${template.id}]`);
    this.args.closeModal();
  }

  <template>
    <DModal
      @title={{i18n "form_embed.insert_form"}}
      @closeModal={{@closeModal}}
      class="form-template-chooser-modal"
    >
      <:body>
        {{#if this.loading}}
          <div class="spinner"></div>
        {{else if this.formTemplates.length}}
          <ul class="form-template-list">
            {{#each this.formTemplates as |template|}}
              <li>
                <DButton
                  @action={{fn this.selectTemplate template}}
                  class="btn-default form-template-item"
                >
                  {{template.name}}
                </DButton>
              </li>
            {{/each}}
          </ul>
        {{else}}
          <p>{{i18n "form_embed.no_templates"}}</p>
        {{/if}}
      </:body>
    </DModal>
  </template>
}
