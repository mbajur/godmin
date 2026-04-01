import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["selectAll", "selectNone", "checkbox", "checkboxContainer"]

  connect() {
    this.updateState()
  }

  toggle(event) {
    event.preventDefault()
    if (this.anyChecked()) {
      this.checkboxTargets.forEach(cb => { cb.checked = false })
    } else {
      this.checkboxTargets.forEach(cb => { cb.checked = true })
    }
    this.updateState()
  }

  containerClick(event) {
    if (event.currentTarget === event.target) {
      event.currentTarget.querySelector("[data-batch-actions-target='checkbox']").click()
    }
  }

  checkboxChange() {
    this.updateState()
  }

  anyChecked() {
    return this.checkboxTargets.some(cb => cb.checked)
  }

  updateState() {
    if (this.anyChecked()) {
      this.selectAllTargets.forEach(el => el.classList.add("d-none"))
      this.selectNoneTargets.forEach(el => el.classList.remove("d-none"))
    } else {
      this.selectAllTargets.forEach(el => el.classList.remove("d-none"))
      this.selectNoneTargets.forEach(el => el.classList.add("d-none"))
    }
  }
}
