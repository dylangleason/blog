(function () {
  // Set the user preferred theme from local storage, if available
  const theme = localStorage.getItem("theme")
  if (theme) {
    document.documentElement.classList.add(theme)
  }

  document.addEventListener("DOMContentLoaded", _ => {
    // Configure hamburger menu on-click event listener
    const hamburgerMenu = document.querySelector(".nav-toggle")
    hamburgerMenu.addEventListener("click", _ => {
      const links = document.querySelector(".links")
      const isOpen = links.classList.toggle("open")
      hamburgerMenu.setAttribute("aria-expanded", isOpen)
    })

    // Configure theme toggle glyph and on-click event listener for changing theme
    const getSystemTheme = () =>
      window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light"

    const toggleTheme = (currentTheme) =>
      currentTheme === "dark" ? "light" : "dark"

    const toggleButton = document.querySelector(".theme-toggle")

    let currentTheme = localStorage.getItem("theme")
    if (!currentTheme) {
      currentTheme = getSystemTheme()
    }

    toggleButton.addEventListener("click", _ => {
      const docElement = document.documentElement
      if (!currentTheme) {
        currentTheme = getSystemTheme()
      } else {
        docElement.classList.remove(currentTheme)
      }
      currentTheme = toggleTheme(currentTheme)
      docElement.classList.add(currentTheme)
      localStorage.setItem("theme", currentTheme)
    })
  })
})()
