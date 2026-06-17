import { apiInitializer } from "discourse/lib/api";
import FormEmbedRenderer from "../components/form-embed-renderer";
import FormTemplateChooser from "../components/modal/form-template-chooser";

export default apiInitializer((api) => {
  api.onToolbarCreate((toolbar) => {
    toolbar.addButton({
      id: "form-embed",
      group: "extras",
      icon: "list-check",
      title: "form_embed.insert_form",
      action: (toolbarEvent) => {
        api.container.lookup("service:modal").show(FormTemplateChooser, {
          model: { toolbarEvent },
        });
      },
      condition: () => {
        const siteSettings = api.container.lookup("service:site-settings");
        const currentUser = api.getCurrentUser();

        if (!siteSettings.discourse_form_embed_enabled) {
          return false;
        }

        if (!currentUser) {
          return false;
        }

        if (currentUser.admin) {
          return true;
        }

        const allowedGroups = (
          siteSettings.discourse_form_embed_allowed_groups || ""
        )
          .split("|")
          .filter(Boolean);

        if (allowedGroups.length === 0) {
          return false;
        }

        const userGroupIds = currentUser.groups.map((g) => String(g.id));

        return allowedGroups.some((groupId) => userGroupIds.includes(groupId));
      },
    });
  });

  api.decorateCookedElement((element, helper) => {
    const formDivs = element.querySelectorAll("div[data-form-id]");

    if (formDivs.length === 0) {
      return;
    }

    formDivs.forEach((formDiv) => {
      const formId = formDiv.getAttribute("data-form-id");

      if (!formId) {
        return;
      }

      const wrapper = document.createElement("div");
      wrapper.classList.add("form-embed-wrapper");
      wrapper.setAttribute("data-form-id", formId);

      helper.renderGlimmer(wrapper, FormEmbedRenderer);
      formDiv.replaceWith(wrapper);
    });
  });
});
