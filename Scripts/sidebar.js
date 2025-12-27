(() => {
    const sidebar = document.getElementById("sidebar");
    const toggleBtn = document.getElementById("sidebarToggle");
    const overlay = document.getElementById("sidebarOverlay");

    if (!sidebar || !toggleBtn || !overlay) return;

    const open = () => {
        sidebar.classList.add("is-open");
        overlay.classList.add("is-open");
        overlay.setAttribute("aria-hidden", "false");
    };

    const close = () => {
        sidebar.classList.remove("is-open");
        overlay.classList.remove("is-open");
        overlay.setAttribute("aria-hidden", "true");
    };

    toggleBtn.addEventListener("click", () => {
        sidebar.classList.contains("is-open") ? close() : open();
    });

    overlay.addEventListener("click", close);

    document.addEventListener("keydown", (e) => {
        if (e.key === "Escape") close();
    });
})();
