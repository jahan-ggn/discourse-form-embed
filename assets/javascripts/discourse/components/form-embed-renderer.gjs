import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn, get } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { eq } from "discourse/truth-helpers";
import { i18n } from "discourse-i18n";
import FormEmbedConsent from "./modal/form-embed-consent";

export default class FormEmbedRenderer extends Component {
  @service modal;

  @tracked formTemplate = null;
  @tracked parsedFields = [];
  @tracked loading = true;
  @tracked error = null;
  @tracked submitting = false;
  @tracked submitSuccess = false;
  @tracked formValues = {};

  formId = null;

  @action
  onElementInsert(element) {
    const wrapper = element.closest(".form-embed-wrapper");
    this.formId = wrapper?.getAttribute("data-form-id");
    if (this.formId) {
      this.loadTemplate();
    }
  }

  async loadTemplate() {
    try {
      const response = await ajax(
        `/discourse-form-embed/template/${this.formId}.json`
      );
      const template = response.form_template;

      this.formTemplate = template;
      this.parsedFields = template.fields;

      const initialValues = {};
      template.fields.forEach((field) => {
        if (field.type === "checkbox") {
          initialValues[field.id] = false;
        } else if (field.type === "multi-select") {
          initialValues[field.id] = [];
        } else {
          initialValues[field.id] = "";
        }
      });
      this.formValues = initialValues;
    } catch (e) {
      this.error = e.message || i18n("form_embed.load_error");
    } finally {
      this.loading = false;
    }
  }

  @action
  onInputChange(fieldId, event) {
    this.formValues = { ...this.formValues, [fieldId]: event.target.value };
  }

  @action
  onCheckboxChange(fieldId, event) {
    this.formValues = { ...this.formValues, [fieldId]: event.target.checked };
  }

  @action
  onSelectChange(fieldId, event) {
    this.formValues = { ...this.formValues, [fieldId]: event.target.value };
  }

  @action
  onMultiSelectChange(fieldId, choice, event) {
    const currentValues = [...(this.formValues[fieldId] || [])];
    if (event.target.checked) {
      currentValues.push(choice);
    } else {
      const index = currentValues.indexOf(choice);
      if (index > -1) {
        currentValues.splice(index, 1);
      }
    }
    this.formValues = { ...this.formValues, [fieldId]: currentValues };
  }

  @action
  onSubmit(event) {
    event.preventDefault();
    if (!event.target.checkValidity()) {
      return;
    }

    const fieldSummary = this.parsedFields.map((field) => ({
      label: field.attributes?.label || field.id,
      value: this.formValues[field.id],
    }));

    this.modal.show(FormEmbedConsent, {
      model: {
        fields: fieldSummary,
        onConfirm: () => this._doSubmit(),
      },
    });
  }

  @action
  async _doSubmit() {
    this.submitting = true;
    try {
      const payload = {
        form_id: this.formId,
        form_name: this.formTemplate.name,
        data: this.formValues,
      };
      await ajax("/discourse-form-embed/submit", {
        type: "POST",
        data: payload,
      });
      this.submitSuccess = true;
    } catch (e) {
      popupAjaxError(e);
    } finally {
      this.submitting = false;
    }
  }

  <template>
    <div {{didInsert this.onElementInsert}} class="form-embed-renderer">
      {{#if this.loading}}
        <div class="spinner"></div>
      {{else if this.error}}
        <div class="alert alert-error">{{this.error}}</div>
      {{else if this.submitSuccess}}
        <div class="alert alert-success">{{i18n
            "form_embed.submit_success"
          }}</div>
      {{else}}
        <form {{on "submit" this.onSubmit}} class="form-embed-form">
          {{#each this.parsedFields as |field|}}
            <div class="form-embed-field control-group">
              {{#if field.attributes.label}}
                {{#unless (eq field.type "checkbox")}}
                  <label class="form-embed-label" for={{field.id}}>
                    {{field.attributes.label}}
                    {{#if field.validations.required}}
                      <span class="form-embed-required">*</span>
                    {{/if}}
                  </label>
                {{/unless}}
              {{/if}}
              {{#if field.attributes.description}}
                <p
                  class="form-embed-description"
                >{{field.attributes.description}}</p>
              {{/if}}

              {{#if (eq field.type "input")}}
                <input
                  type="text"
                  id={{field.id}}
                  name={{field.id}}
                  class="form-embed-input"
                  placeholder={{field.attributes.placeholder}}
                  required={{field.validations.required}}
                  minlength={{field.validations.minimum}}
                  maxlength={{field.validations.maximum}}
                  value={{get this.formValues field.id}}
                  {{on "input" (fn this.onInputChange field.id)}}
                />
              {{else if (eq field.type "textarea")}}
                <textarea
                  id={{field.id}}
                  name={{field.id}}
                  class="form-embed-textarea"
                  placeholder={{field.attributes.placeholder}}
                  required={{field.validations.required}}
                  minlength={{field.validations.minimum}}
                  maxlength={{field.validations.maximum}}
                  {{on "input" (fn this.onInputChange field.id)}}
                >{{get this.formValues field.id}}</textarea>
              {{else if (eq field.type "dropdown")}}
                <select
                  id={{field.id}}
                  name={{field.id}}
                  class="form-embed-select"
                  required={{field.validations.required}}
                  {{on "change" (fn this.onSelectChange field.id)}}
                >
                  {{#if field.attributes.none_label}}
                    <option value="">{{field.attributes.none_label}}</option>
                  {{/if}}
                  {{#each field.choices as |choice|}}
                    <option value={{choice}}>{{choice}}</option>
                  {{/each}}
                </select>
              {{else if (eq field.type "multi-select")}}
                <div class="form-embed-multi-select">
                  {{#each field.choices as |choice|}}
                    <label class="form-embed-checkbox-label">
                      <input
                        type="checkbox"
                        name={{field.id}}
                        value={{choice}}
                        {{on
                          "change"
                          (fn this.onMultiSelectChange field.id choice)
                        }}
                      />
                      {{choice}}
                    </label>
                  {{/each}}
                </div>
              {{else if (eq field.type "upload")}}
                <input
                  type="file"
                  id={{field.id}}
                  name={{field.id}}
                  class="form-embed-upload"
                  accept={{field.attributes.file_types}}
                  {{on "change" (fn this.onInputChange field.id)}}
                />
              {{else if (eq field.type "checkbox")}}
                <div class="form-embed-checkbox-wrapper">
                  <input
                    type="checkbox"
                    id={{field.id}}
                    name={{field.id}}
                    class="form-embed-checkbox"
                    required={{field.validations.required}}
                    checked={{get this.formValues field.id}}
                    {{on "change" (fn this.onCheckboxChange field.id)}}
                  />
                  <label for={{field.id}} class="form-embed-checkbox-label">
                    {{field.attributes.label}}
                    {{#if field.validations.required}}
                      <span class="form-embed-required">*</span>
                    {{/if}}
                  </label>
                </div>
              {{/if}}
            </div>
          {{/each}}

          <div class="form-embed-footer">
            <button
              type="submit"
              class="btn btn-primary"
              disabled={{this.submitting}}
            >
              {{#if this.submitting}}
                <div class="spinner"></div>
              {{else}}
                {{i18n "form_embed.submit"}}
              {{/if}}
            </button>
          </div>
        </form>
      {{/if}}
    </div>
  </template>
}
