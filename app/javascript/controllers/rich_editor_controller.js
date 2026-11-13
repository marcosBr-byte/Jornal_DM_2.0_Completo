import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["editor", "count"]

  connect() {
    this.initialValue = document.getElementById(this.editorTarget.getAttribute("input"))?.value || ""
    this.form = this.element.closest("form")
    this.onReset = () => requestAnimationFrame(() => {
      if (this.editorTarget.editor) {
        this.editorTarget.editor.loadHTML(this.initialValue)
        this.changed()
      }
    })
    this.form?.addEventListener("reset", this.onReset)
    this.changed()
  }

  disconnect() {
    this.form?.removeEventListener("reset", this.onReset)
  }

  changed() {
    const text = this.editorTarget.editor?.getDocument().toString() || this.editorTarget.textContent || ""
    const words = text.trim().split(/\s+/u).filter(Boolean).length
    this.countTarget.textContent = words === 1 ? "1 palavra" : `${words} palavras`
    this.editorTarget.setCustomValidity?.(text.replace(/[\s\u00a0\u200b]/gu, "") ? "" : "Escreva o conteúdo da notícia.")
  }

  rejectFile(event) {
    // Images continue using the validated cover upload field.
    event.preventDefault()
  }
}
