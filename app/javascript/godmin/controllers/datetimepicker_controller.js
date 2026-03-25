import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { type: String }

  connect() {
    if (typeof $ === "undefined" || !$.fn.datetimepicker) return

    const options = {}
    if (this.typeValue === "date") {
      options.pickTime = false
    } else if (this.typeValue === "time") {
      options.pickDate = false
    }

    $(this.element).datetimepicker(options)
  }

  disconnect() {
    if (typeof $ === "undefined" || !$.fn.datetimepicker) return
    const picker = $(this.element).data("DateTimePicker")
    if (picker) picker.destroy()
  }
}
