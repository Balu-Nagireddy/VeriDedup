<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - VeriDedup</title>
    <link rel="stylesheet" href="styles.css">
    <script>
        function validateForm() {
            var email = document.getElementById('email').value;
            var mobile = document.getElementById('mobile').value;
            var password = document.getElementById('password').value;

            // Email validation
            var emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailPattern.test(email)) {
                alert("Please enter a valid email address.");
                return false;
            }

            // Mobile number validation
            var mobilePattern = /^\d{10}$/;
            if (!mobilePattern.test(mobile)) {
                alert("Please enter a valid 10-digit mobile number.");
                return false;
            }

            // Password validation
            var passwordPattern = ^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$
            if (!passwordPattern.test(password)) {
                alert("Minimum 8 characters, at least one uppercase letter, one lowercase letter, one number and one special character");
                return false;
            }

            return true;
        }

        /* function showPopup() {
            alert("Registration successful! Waiting for admin approval.");
            // Redirect to another page or perform additional actions if needed
            window.location.href = "welcome.jsp";
        } */

        /* function refreshCaptcha() {
            document.getElementById('captchaImage').src = 'generateCaptcha.jsp?' + new Date().getTime();
        } */
    </script>
</head>
<body>
    <header>
        <h1>Welcome to VeriDedup</h1>
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
                <li><a href="register.jsp" class="active">Register</a></li>
                <li><a href="contact.jsp">Contact Us</a></li>
                <li><a href="about.jsp">About Us</a></li>
            </ul>
        </nav>
    </header>

    <section>
        <h2>Register</h2>
        <form action="registerDB.jsp" method="post" onsubmit="return validateForm() && showPopup()">
            <label for="firstName">First Name</label>
            <input type="text" id="firstName" name="firstName" required>

            <label for="lastName">Last Name</label>
            <input type="text" id="lastName" name="lastName" required>

            <label for="dob">Date of Birth</label>
            <input type="date" id="dob" name="dob" required>

            <label for="mobile">Mobile Number</label>
            <input type="tel" id="mobile" name="mobile" required pattern="\d{10}" title="Please enter a 10-digit mobile number">

            <label for="email">Email</label>
            <input type="email" id="email" name="email" required>

            <label for="password">Password</label>
            <input type="password" id="password" name="password" required minlength="8" title="Minimum 8 characters, at least one uppercase letter, one lowercase letter, one number and one special character">

            <label for="gender">Gender</label>
            <select id="gender" name="gender" required>
            	<option value="" disabled selected>Select Gender</option>
                <option value="male">Male</option>
                <option value="female">Female</option>
                <option value="other">Other</option>
            </select>
            <label for="captcha">Enter Captcha:</label>
            <input type="text" id="captcha" name="captcha" required>
            <img src="generateCaptcha.jsp" alt="Captcha Image" id="captchaImage">

            <button type="submit">Register</button>
        </form>
    </section>

    <script src="script.js"></script>
    <footer>
	    <p>© 2025 VeriDedup | Secure Data Deduplication</p>
	</footer>
</body>
</html>
