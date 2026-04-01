import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["selectAll", "selectNone", "checkbox", "checkboxContainer", "actionLink"]

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

  triggerAction(event) {
    event.preventDefault()
    const link = event.currentTarget
    const confirmMessage = link.dataset.confirm
    if (confirmMessage && !window.confirm(confirmMessage)) return

    const action = link.getAttribute("href") + "/" + this.checkedIds().join(",")
    const batchAction = link.dataset.value
    const csrfToken = document.querySelector("meta[name='csrf-token']")?.content

    const form = document.createElement("form")
    form.method = "post"
    form.action = action

    const methodInput = document.createElement("input")
    methodInput.type = "hidden"
    methodInput.name = "_method"
    methodInput.value = "patch"
    form.appendChild(methodInput)

    const batchInput = document.createElement("input")
    batchInput.type = "hidden"
    batchInput.name = "batch_action"
    batchInput.value = batchAction
    form.appendChild(batchInput)

    if (csrfToken) {
      const csrfInput = document.createElement("input")
      csrfInput.type = "hidden"
      csrfInput.name = "authenticity_token"
      csrfInput.value = csrfToken
      form.appendChild(csrfInput)
    }

    document.body.appendChild(form)
    form.dataset.turbo = "false"
    form.submit()
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
      this.actionLinkTargets.forEach(el => el.classList.remove("d-none"))
      this.showSelectNone()
    } else {
      this.actionLinkTargets.forEach(el => el.classList.add("d-none"))
      this.showSelectAll()
    }
  }

  updateState() {
    this.updateActions()
  }
}
