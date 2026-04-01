import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["selectAll", "selectNone", "checkbox", "checkboxContainer", "actionButton"]

  connect() {
    this.updateState()
  }

  toggle(event) {
    event.preventDefault()
    if (this.checkedIds().length > 0) {
      this.checkboxTargets.forEach(cb => { cb.checked = false })
    } else {
      this.checkboxTargets.forEach(cb => { cb.checked = true })
    }
    this.updateActions()
  }

  containerClick(event) {
    if (event.currentTarget === event.target) {
      event.currentTarget.querySelector("[data-batch-actions-target='checkbox']").click()
    }
  }

  checkboxChange() {
    this.updateActions()
  }

  prepareAction(event) {
    const ids = this.checkedIds()
    if (ids.length === 0) {
      event.preventDefault()
      return
    }

    const button = event.submitter
    const confirmMessage = button?.dataset.confirm
    if (confirmMessage && !window.confirm(confirmMessage)) {
      event.preventDefault()
      return
    }

    event.currentTarget.action = event.currentTarget.dataset.resourcePath + "/" + ids.join(",")
  }

  checkedIds() {
    return this.checkboxTargets
      .filter(cb => cb.checked)
      .map(cb => {
        const match = cb.id.match(/\d+/)
        return match ? match[0] : null
      })
      .filter(id => id !== null)
  }

  showSelectAll() {
    this.selectAllTargets.forEach(el => el.classList.remove("d-none"))
    this.selectNoneTargets.forEach(el => el.classList.add("d-none"))
  }

  showSelectNone() {
    this.selectAllTargets.forEach(el => el.classList.add("d-none"))
    this.selectNoneTargets.forEach(el => el.classList.remove("d-none"))
  }

  updateActions() {
    if (this.checkedIds().length > 0) {
      this.actionButtonTargets.forEach(el => el.classList.remove("d-none"))
      this.showSelectNone()
    } else {
      this.actionButtonTargets.forEach(el => el.classList.add("d-none"))
      this.showSelectAll()
    }
  }

  updateState() {
    this.updateActions()
  }
}
