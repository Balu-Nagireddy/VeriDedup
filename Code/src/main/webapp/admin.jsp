<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login - VeriDedup</title>
    <link rel="stylesheet" href="styles1.css">
    <script>
        function showError(message) {
            document.getElementById('error-message').innerText = message;
        }

        function validateForm(event) {
            event.preventDefault();
            const email = document.getElementById('email').value;
            const password = document.getElementById('password').value;
            const captcha = document.getElementById('captcha').value;

            if (email.trim() === "" || password.trim() === "" || captcha.trim() === "") {
                showError("All fields are required.");
                return;
            }

            // Submit the form if validation passes
            document.getElementById('login-form').submit();
        }

        function refreshCaptcha() {
            document.getElementById('captchaImage').src = 'generateCaptcha.jsp?' + new Date().getTime();
        }
    </script>
</head>
<body>
    <div class="login-container">
        <h2>Admin Login</h2>
        <%
		    String errorMessage = (String) session.getAttribute("errorMessage");
		    if (errorMessage != null) {
		%>
		    <div style="color: red; text-align: center; font-weight: bold; margin-bottom: 10px;">
		        <%= errorMessage %>
		    </div>
		<%
		        session.removeAttribute("errorMessage"); // Clear the message after displaying it once
		    }
		%>
        <form id="login-form" action="adminLogin.jsp" method="post">
            <input type="email" id="email" name="email" placeholder="email" required>
            <input type="password" id="password" name="password" placeholder="Password" required>
            <div class="captcha-container">
                <img src="generateCaptcha.jsp" alt="Captcha Image" id="captchaImage">
                <button type="button" onclick="refreshCaptcha()">Refresh</button>
            </div>
            <input type="text" id="captcha" name="captcha" placeholder="Enter Captcha" required>
            <button type="button" onclick="validateForm(event)">Login</button>
        </form>
        <p id="error-message" class="error-message"></p>
    </div>
    <script src="script.js" defer></script>
    <footer>
	    <p>© 2025 VeriDedup | Secure Data Deduplication</p>
	</footer>
</body>
</html>
