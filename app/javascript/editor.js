import "trix"

// Local Trix asset provided by Rails; no external editor service is needed.
window.Trix.config.blockAttributes.heading1.tagName = "h2"
Object.assign(window.Trix.config.lang, {
  bold: "Negrito", italic: "Itálico", strike: "Tachado", link: "Inserir link",
  heading1: "Título", quote: "Citação", code: "Código", bullets: "Lista",
  numbers: "Lista numerada", undo: "Desfazer", redo: "Refazer",
  url: "Endereço do link", urlPlaceholder: "https://...", unlink: "Remover link"
})
