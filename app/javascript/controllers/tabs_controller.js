import { Controller } from "@hotwired/stimulus"

// Segmented tab switcher (used by the combined Pips card).
export default class extends Controller {
  static targets = [ "tab", "panel" ]
  static values = { index: Number }

  connect() {
    this.render()
  }

  show(event) {
    this.indexValue = parseInt(event.currentTarget.dataset.index, 10)
    this.render()
  }

  render() {
    this.tabTargets.forEach((tab, i) => {
      const active = i === this.indexValue
      tab.classList.toggle("bg-white", active)
      tab.classList.toggle("shadow-sm", active)
      tab.classList.toggle("text-gray-900", active)
      tab.classList.toggle("text-gray-500", !active)
    })
    // inline style, not [hidden]: the panels carry display classes that outrank it
    this.panelTargets.forEach((panel, i) => { panel.style.display = i === this.indexValue ? "" : "none" })
  }
}
