import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    if (typeof $ === "undefined" || !$.fn.selectize) return

    const addLabel = this.element.dataset.addLabel

    $(this.element).selectize({
      inputClass: "selectize-input",
      render: {
        option_create(data, escape) {
          return `<div class="create">${addLabel || "+"} <strong>${escape(data.input)}</strong>&hellip;</div>`
        }
      }
    })
  }

  disconnect() {
    if (this.element.selectize) {
      this.element.selectize.destroy()
    }
  }
}
