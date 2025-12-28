(() => {
    const frame = document.querySelector(".app-frame");
    const toggleBtn = document.getElementById("sidebarToggle");
    const overlay = document.getElementById("sidebarOverlay");

    if (!frame || !toggleBtn || !overlay) return;

    const close = () => frame.classList.remove("is-open");

    toggleBtn.addEventListener("click", () => {
        const isOpen = frame.classList.toggle("is-open");
        toggleBtn.setAttribute("aria-expanded", isOpen);
    });


    overlay.addEventListener("click", close);

    document.addEventListener("keydown", (e) => {
        if (e.key === "Escape") close();
    });
})();
