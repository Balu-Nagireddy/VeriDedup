<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>CSP Login - VeriDedup</title>
    <link rel="stylesheet" href="styles.css">
    <script>
        function refreshCaptcha() {
            document.getElementById('captchaImage').src = 'generateCaptcha.jsp?' + new Date().getTime();
        }

        function validateForm(event) {
            const email = document.getElementById('email').value.trim();
            const password = document.getElementById('password').value.trim();
            const captcha = document.getElementById('captcha').value.trim();

            if (email === "" || password === "" || captcha === "") {
                alert("🚨 All fields are required!");
                event.preventDefault(); // ❌ Prevent form submission if invalid
                return false;
            }

            return true; // ✅ Allow form submission
        }
    </script>
    <style>
		body {
		    font-family: 'Poppins', sans-serif;
		    background: linear-gradient(to right, #141E30, #243B55);
		    color: white;
		    text-align: center;
		    display: flex;
		    justify-content: center;
		    align-items: center;
		    height: 100vh;
		    margin: 0;
		}
		
		.login-container {
		    background: rgba(255, 255, 255, 0.1);
		    padding: 40px;
		    border-radius: 12px;
		    box-shadow: 0px 5px 15px rgba(0, 0, 0, 0.2);
		    width: 400px;
		}
		
		.login-container h2 {
		    margin-bottom: 20px;
		    color: #ff9800;
		}
		
		.login-container input {
		    width: 100%;
		    padding: 12px; /* ⬆ Increased padding for better spacing */
		    margin: 12px 0; /* ⬆ Added more space between fields */
		    border: none;
		    border-radius: 5px;
		    font-size: 16px;
		}
		
		.captcha-container {
		    display: flex;
		    justify-content: center;
		    align-items: center;
		    margin-top: 15px;
		}
		
		.captcha-container img {
		    height: 40px; /* ⬆ Adjusted CAPTCHA size */
		    margin-right: 15px;
		    border-radius: 5px;
		}
		
		.captcha-container input {
		    width: 100px; /* ⬆ Increased width so full CAPTCHA is visible */
		    padding: 10px;
		    font-size: 16px;
		    text-align: center;
		}
		
		.login-container button {
		    width: 100%;
		    padding: 14px; /* ⬆ Increased button size */
		    border: none;
		    border-radius: 5px;
		    background: #ff9800;
		    color: white;
		    font-size: 16px;
		    cursor: pointer;
		    transition: background 0.3s ease-in-out;
		    margin-top: 15px;
		}
		
		.login-container button:hover {
		    background: #e68900;
		}
		footer{
			position : absolute;
    		bottom : 0;
		}
    </style>
</head>
<body>

    <div class="login-container">
        <h2>CSP Login</h2>
        <%
		    String errorMsg = request.getParameter("error");
		    String displayError = "";
		    if ("InvalidCredentials".equals(errorMsg)) {
		        displayError = "Invalid email or password!";
		    } else if ("InvalidCaptcha".equals(errorMsg)) {
		        displayError = "Incorrect CAPTCHA!";
		    } else if ("UnauthorizedAccess".equals(errorMsg)) {
		        displayError = "Session expired. Please log in again.";
		    }
		%>
		
		<% if (!displayError.isEmpty()) { %>
		    <p style="color: red; font-weight: bold;"><%= displayError %></p>
		<% } %>
        <form id="loginForm" action="host_authenticate.jsp" method="post" onsubmit="return validateForm(event)">
            <input type="email" id="email" name="email" placeholder="Email" required><br>
            <input type="password" id="password" name="password" placeholder="Password" required><br>

            <!-- CAPTCHA -->
            <div class="captcha-container">
                <img src="generateCaptcha.jsp" alt="Captcha" id="captchaImage" onclick="refreshCaptcha()">
                <input type="text" id="captcha" name="captcha" placeholder="Enter CAPTCHA" required>
            </div>

            <!-- ✅ FIXED: Set `type="submit"` for the button -->
            <button type="submit">Login</button>
        </form>
    </div>
    <script src="script.js" defer></script>
    <footer>
	    <p>© 2025 VeriDedup | Secure Data Deduplication</p>
	</footer>

</body>
</html>
