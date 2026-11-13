import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggle", "icon", "label"]

  connect() {
    let dark = false
    try { dark = localStorage.getItem("jornaldm_theme") === "dark" } catch {}
    this.apply(dark)
  }

  toggle() {
    const dark = !document.documentElement.classList.contains("dark")
    this.apply(dark)
    try { localStorage.setItem("jornaldm_theme", dark ? "dark" : "light") } catch {}
  }

  apply(dark) {
    document.documentElement.classList.toggle("dark", dark)
    this.iconTargets.forEach((icon) => { icon.textContent = dark ? "☀" : "☾" })
    this.labelTargets.forEach((label) => { label.textContent = dark ? "Modo claro" : "Modo noturno" })
    this.toggleTargets.forEach((button) => {
      if (!button.querySelector('[data-theme-target~="icon"]')) {
        button.textContent = dark ? "☀" : "☾"
      }
      button.setAttribute("aria-pressed", String(dark))
      button.setAttribute("aria-label", dark ? "Ativar tema claro" : "Ativar tema escuro")
    })
  }
}
