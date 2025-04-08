<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.HttpSession" %>

<%
    // ✅ Ensure user is logged in
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("Email") == null) {
        response.sendRedirect("client.jsp?error=SessionExpired");
        return;
    }

    String userEmail = (String) userSession.getAttribute("Email");
    int userId = -1; // Default if not found

    try {
        // ✅ Retrieve `user_id` from `users` table
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/VeriDedup", "root", "Rgukt143");

        String query = "SELECT id FROM users WHERE email = ?";
        PreparedStatement ps = connection.prepareStatement(query);
        ps.setString(1, userEmail);
        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            userId = rs.getInt("id");
            userSession.setAttribute("user_id", userId); // ✅ Store `user_id` in session
        }

        rs.close();
        ps.close();
        connection.close();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Secure File Upload - VeriDedup</title>
    <link rel="stylesheet" href="styles.css">
    
    <script>
        function validateFile() {
            let fileInput = document.getElementById("file");
            let fileName = document.getElementById("fileName");
            let verificationTag = document.getElementById("verificationTag");

            if (!fileInput.files[0]) {
                alert("🚨 Please select a file before uploading.");
                return false;
            }

            if (!fileName.value.trim()) {
                alert("🚨 Please enter a valid file name.");
                return false;
            }

            if (!verificationTag.value.trim()) {
                alert("🚨 Please enter a verification tag to ensure file integrity.");
                return false;
            }
            return true;
        }

        function updateFileName() {
            let fileInput = document.getElementById("file");
            let fileName = document.getElementById("fileName");
            if (fileInput.files.length > 0) {
                fileName.value = fileInput.files[0].name; 
            }
        }
    </script>

    <style>
        body {
            font-family: 'Poppins', sans-serif;
            background: linear-gradient(to right, #004e92, #000428);
            color: white;
            text-align: center;
            padding: 20px;
        }

        .upload-container {
            max-width: 500px;
            background: white;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0px 10px 20px rgba(0, 0, 0, 0.15);
            margin: 50px auto;
            text-align: center;
            transition: transform 0.3s ease-in-out;
            color: black;
        }

        .upload-container:hover {
            transform: scale(1.02);
        }

        h2 {
            color: #0073e6;
            font-size: 24px;
            margin-bottom: 20px;
        }

        .file-input {
            background: #f9f9f9;
            padding: 10px;
            border-radius: 8px;
            margin-bottom: 15px;
            display: flex;
            flex-direction: column;
            align-items: center;
            border: 2px dashed #0073e6;
            transition: border 0.3s ease-in-out;
        }

        .file-input:hover {
            border: 2px dashed #005bb5;
        }

        input[type="file"] {
            display: none;
        }

        .custom-file-upload {
            background: #0073e6;
            color: white;
            padding: 10px 15px;
            border-radius: 5px;
            cursor: pointer;
            transition: background 0.3s ease-in-out;
            display: inline-block;
        }

        .custom-file-upload:hover {
            background: #005bb5;
        }

        input[type="text"] {
            width: 100%;
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 5px;
            font-size: 16px;
            margin-top: 10px;
        }

        .upload-btn {
            background: #0d47a1;
            color: white;
            border: none;
            padding: 12px;
            border-radius: 5px;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            transition: background 0.3s ease-in-out;
            width: 100%;
            margin-top: 15px;
        }

        .upload-btn:hover {
            background: #08306e;
        }

        .back-link {
            display: block;
            margin-top: 15px;
            text-decoration: none;
            color: #0073e6;
            font-weight: bold;
            transition: color 0.3s ease-in-out;
        }

        .back-link:hover {
            color: #005bb5;
        }
    </style>
    <script>
	document.addEventListener("DOMContentLoaded", function() {
	    const params = new URLSearchParams(window.location.search);
	    if (params.get("forceUpload") === "true") {
	        document.getElementById("forceUpload").value = "true";
	    }
	});
	</script> 
</head>

<body>

    <div class="upload-container">
        <h2>🔒 Secure File Upload</h2>

        <form id="uploadForm" action="UploadFileServlet" method="post" enctype="multipart/form-data" onsubmit="return validateFile();">
            <label class="file-input">
                <span class="custom-file-upload">📂 Select File</span>
                <input type="file" name="file" id="file" onchange="updateFileName()" required />
                <input type="hidden" id="forceUpload" name="forceUpload" value="false">
            </label>

            <input type="text" name="fileName" id="fileName" placeholder="Enter File Name" required />

            <!-- ✅ User enters verification tag -->
            <input type="text" name="verificationTag" id="verificationTag" placeholder="Enter Verification Tag" required />

            <!-- ✅ Pass user_id dynamically -->
            <input type="hidden" name="user_id" value="<%= userId %>">

            <button type="submit" class="upload-btn">🚀 Upload & Encrypt</button>
        </form>

        <a href="client_dashboard.jsp" class="back-link">⬅ Back to Dashboard</a>
    </div>

    <footer>
        <p>© 2025 VeriDedup | Secure Data Deduplication</p>
    </footer>

</body>
</html>
