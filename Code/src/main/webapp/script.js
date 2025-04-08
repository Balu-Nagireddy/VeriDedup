document.addEventListener('DOMContentLoaded', function() {
    // Dropdown menu handling
    const dropdown = document.querySelector('nav ul li:nth-child(2)'); // Assuming "Login" is the second item
    const dropdownMenu = dropdown.querySelector('ul');
    const bodyContent = document.querySelector('section'); // Adjust selector as needed

    dropdown.addEventListener('mouseenter', function() {
        dropdownMenu.style.display = 'block';
        dropdownMenu.style.opacity = '1';
        dropdownMenu.style.transform = 'translateY(0)';
        bodyContent.style.marginTop = '150px'; // Adjust based on dropdown height
    });

    dropdown.addEventListener('mouseleave', function() {
        dropdownMenu.style.opacity = '0';
        dropdownMenu.style.transform = 'translateY(-10px)';
        setTimeout(() => {
            dropdownMenu.style.display = 'none';
            bodyContent.style.marginTop = '0';
        }, 300); // Match the transition duration
    });

    // Dark mode toggle button
    const toggleButton = document.createElement('button');
    toggleButton.textContent = '🌙 Dark Mode';
    toggleButton.classList.add('dark-mode-toggle');
    toggleButton.style.position = "fixed";
    toggleButton.style.top = "20px";
    toggleButton.style.right = "20px";
    toggleButton.style.padding = "10px 15px";
    toggleButton.style.background = "#0073e6";
    toggleButton.style.color = "#fff";
    toggleButton.style.border = "none";
    toggleButton.style.cursor = "pointer";
    toggleButton.style.borderRadius = "5px";
    toggleButton.style.transition = "background 0.3s ease";
    document.body.appendChild(toggleButton);

    if (localStorage.getItem('darkMode') === 'enabled') {
        document.body.classList.add('dark-mode');
        toggleButton.textContent = "☀️ Light Mode";
    }

    toggleButton.addEventListener('click', function() {
        document.body.classList.toggle('dark-mode');
        if (document.body.classList.contains('dark-mode')) {
            localStorage.setItem('darkMode', 'enabled');
            toggleButton.textContent = "☀️ Light Mode";
        } else {
            localStorage.setItem('darkMode', 'disabled');
            toggleButton.textContent = "🌙 Dark Mode";
        }
    });

    // Smooth scrolling for navigation links
    const links = document.querySelectorAll("nav ul li a");
    links.forEach(link => {
        link.addEventListener("click", function(event) {
            event.preventDefault(); // Prevent default jump behavior
            const targetId = this.getAttribute("href").split(".jsp")[0]; // Extract page name
            const targetSection = document.querySelector("section");

            if (targetSection) {
                window.scrollTo({
                    top: targetSection.offsetTop - 50,
                    behavior: "smooth"
                });
            }

            // Remove 'active' class from all links and add to the clicked one
            links.forEach(l => l.classList.remove("active"));
            this.classList.add("active");

            // Ensure proper navigation
            window.location.href = this.href;
        });
    });

    // Fade-in animation for content
    const section = document.querySelector("section");
    section.style.opacity = "0";
    section.style.transform = "translateY(20px)";
    setTimeout(() => {
        section.style.transition = "opacity 1s ease, transform 1s ease";
        section.style.opacity = "1";
        section.style.transform = "translateY(0)";
    }, 300);
});
