<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Contact Us</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>

<header>
    <h1>Contact Us</h1>
    <nav>
            <ul>
                <li><a href="welcome.jsp">Home</a></li>
                <li>
                    <a href="#">Login</a>
                    <ul>
                        <li><a href="admin.jsp">Admin</a></li>
                        <li><a href="client.jsp">Client</a></li>
                        <li><a href="host.jsp">Host</a></li>
                    </ul>
                </li>
                <li><a href="register.jsp">Register</a></li>
                <li><a href="contact.jsp" class="active">Contact Us</a></li>
                <li><a href="about.jsp">About Us</a></li>
            </ul>
        </nav>
</header>

<section>
    <h2>Get in Touch</h2>
    <p>If you have any questions, feel free to contact us using the form below:</p>

    <form action="sendContactForm.jsp" method="post">
        <label for="name">Full Name:</label>
        <input type="text" id="name" name="name" required>

        <label for="email">Email Address:</label>
        <input type="email" id="email" name="email" required>

        <label for="message">Your Message:</label>
        <textarea id="message" name="message" rows="5" required></textarea>

        <button type="submit">Send Message</button>
    </form>

    <h3>Our Office</h3>
    <p>📍 123 VeriDedup Street, Secure City, SC 56789</p>
    <p>📞 +91 8978238089</p>
    <p>📧 support@veridedup.com</p>
</section>
<script src="script.js" defer></script>

<footer>
    <p>© 2025 VeriDedup | Secure Data Deduplication</p>
</footer>

</body>
</html>
