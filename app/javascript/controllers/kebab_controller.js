import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]
  static values = { url: String }

  toggle(event) {
    event.stopPropagation()
    this.menuTarget.classList.toggle("hidden")
  }

  close() {
    this.menuTarget.classList.add("hidden")
  }

  async copyLink(event) {
    event.preventDefault()
    await navigator.clipboard.writeText(this.urlValue)
    this.close()
  }
}
