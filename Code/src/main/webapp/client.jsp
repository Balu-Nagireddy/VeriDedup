<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Client Login - VeriDedup</title>
    <link rel="stylesheet" href="styles.css">

    <style>
        body {
            font-family: 'Poppins', sans-serif;
            background: linear-gradient(to right, #004e92, #000428);
            color: white;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }

        .login-container {
            background: rgba(255, 255, 255, 0.1);
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0px 5px 15px rgba(0, 0, 0, 0.2);
            text-align: center;
            width: 350px;
        }

        .login-container h2 {
            margin-bottom: 20px;
            font-size: 24px;
        }

        .login-container input {
            width: 90%;
            padding: 12px;
            border: none;
            border-radius: 5px;
            margin: 10px 0;
            font-size: 16px;
            text-align: center;
        }

        .login-container button {
            background: #ff9800;
            border: none;
            padding: 12px;
            color: white;
            width: 100%;
            font-size: 18px;
            border-radius: 5px;
            cursor: pointer;
            transition: background 0.3s ease-in-out;
        }

        .login-container button:hover {
            background: #e68900;
        }

        .error-message {
            color: #ff4444;
            font-size: 14px;
        }

        .captcha-container {
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .captcha-container img {
            border-radius: 5px;
            margin-right: 10px;
            cursor: pointer;
        }

    </style>

    <script>
        function refreshCaptcha() {
            document.getElementById('captchaImage').src = 'generateCaptcha.jsp?' + new Date().getTime();
        }
    </script>
</head>
<body>

    <div class="login-container">
        <h2>🔐 Client Login</h2>

        <!-- Error Message Display -->
        <p class="error-message">
            <% if (session.getAttribute("error") != null) { 
                out.print(session.getAttribute("error"));
                session.removeAttribute("error");
            } %>
        </p>

        <form action="clientLogin.jsp" method="post">
            <input type="email" name="email" placeholder="Email" required>
            <input type="password" name="password" placeholder="Password" required>

            <div class="captcha-container">
                <img src="generateCaptcha.jsp" alt="Captcha" id="captchaImage" onclick="refreshCaptcha()">
            </div>
            <input type="text" name="captcha" placeholder="Enter Captcha" required>

            <button type="submit">Login</button>
        </form>
    </div>

</body>
</html>
