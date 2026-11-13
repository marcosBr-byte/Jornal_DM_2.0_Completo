import "@hotwired/turbo-rails"
import "controllers"
import "editor"
document.addEventListener("turbo:load", () => {
  const date = document.querySelector("#todayLabel")
  if (date) date.textContent = new Intl.DateTimeFormat("pt-BR", {dateStyle:"long"}).format(new Date())
  const year = document.querySelector("#year")
  if (year) year.textContent = new Date().getFullYear()
})
