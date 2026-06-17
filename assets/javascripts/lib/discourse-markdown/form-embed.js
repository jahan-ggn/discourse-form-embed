export function setup(helper) {
  helper.registerOptions((opts, siteSettings) => {
    opts.features["form-embed"] = !!siteSettings.discourse_form_embed_enabled;
  });

  if (helper.allowList) {
    helper.allowList(["div.form-embed", "div[data-*]"]);
  } else if (helper.whiteList) {
    helper.whiteList(["div.form-embed", "div[data-*]"]);
  }

  helper.registerPlugin((md) => {
    if (!md.options.discourse.features["form-embed"]) {
      return;
    }

    md.block.ruler.before(
      "paragraph",
      "form-embed",
      (state, startLine, endLine, silent) => {
        const pos = state.bMarks[startLine] + state.tShift[startLine];
        const max = state.eMarks[startLine];

        const marker = "[form=";
        if (state.src.slice(pos, pos + marker.length) !== marker) {
          return false;
        }

        const end = state.src.indexOf("]", pos);
        if (end === -1 || end > max) {
          return false;
        }

        const id = state.src.slice(pos + marker.length, end);
        if (!/^\d+$/.test(id)) {
          return false;
        }

        if (silent) {
          return true;
        }

        const token = state.push("html_block", "", 0);
        token.content = `<div class="form-embed" data-form-id="${id}"></div>`;

        state.line = startLine + 1;
        return true;
      }
    );
  });
}
