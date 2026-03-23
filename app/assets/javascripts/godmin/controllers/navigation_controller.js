import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.setActiveLink()
    this.removeEmptyDropdowns()
  }

  setActiveLink() {
    const pathWithSearch = window.location.pathname + window.location.search
    let links = this.element.querySelectorAll(`.nav.navbar-nav a[href="${pathWithSearch}"]`)

    if (links.length === 0) {
      links = this.element.querySelectorAll(`.nav.navbar-nav a[href="${window.location.pathname}"]`)
    }

    links.forEach(link => {
      link.closest("li")?.classList.add("active")
      link.closest("li.dropdown")?.classList.add("active")
    })
  }

  removeEmptyDropdowns() {
    this.element.querySelectorAll(".navbar-nav .dropdown, .breadcrumb .dropdown").forEach(dropdown => {
      if (dropdown.querySelectorAll("li").length === 0) {
        dropdown.remove()
      }
    })
  }
}
