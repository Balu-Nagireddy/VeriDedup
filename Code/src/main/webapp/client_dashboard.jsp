<%@ page import="java.sql.*, javax.servlet.http.HttpSession" %>
<%! 
    public String formatStorageSize(double sizeInBytes) {
        if (sizeInBytes >= 1_000_000_000) {
            return String.format("%.2f GB", sizeInBytes / 1_000_000_000);
        } else if (sizeInBytes >= 1_000_000) {
            return String.format("%.2f MB", sizeInBytes / 1_000_000);
        } else if (sizeInBytes >= 1_000) {
            return String.format("%.2f KB", sizeInBytes / 1_000);
        } else {
            return sizeInBytes + " Bytes";
        }
    }
%>



<%
    // ✅ Ensure user is logged in
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("Email") == null) {
        response.sendRedirect("client.jsp?error=SessionExpired");
        return;
    }

    // ✅ Retrieve session details
    String userEmail = (String) userSession.getAttribute("Email");
    Integer userId = (Integer) userSession.getAttribute("id"); // ✅ Retrieve user_id from session
    if (userId == null) {
        response.sendRedirect("client.jsp?error=InvalidSession");
        return;
    }
    
    String firstName = (String) userSession.getAttribute("FirstName");
    String lastName = (String) userSession.getAttribute("LastName");

    int totalFiles = 0;
    double totalStorageUsed = 0;

    Connection connection = null;
    PreparedStatement psFiles = null;
    ResultSet rsFiles = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/VeriDedup", "root", "Rgukt143");

        // ✅ Fixed Query: Count files correctly
        String fileQuery = "SELECT COUNT(*) AS totalFiles, COALESCE(SUM(file_size), 0) AS totalStorage FROM files WHERE user_id = ?";
		psFiles = connection.prepareStatement(fileQuery);
		psFiles.setInt(1, userId); // ✅ Fetch files only for this user
		rsFiles = psFiles.executeQuery();


        if (rsFiles.next()) {
            totalFiles = rsFiles.getInt("totalFiles");
            totalStorageUsed = rsFiles.getDouble("totalStorage");
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rsFiles != null) rsFiles.close();
        if (psFiles != null) psFiles.close();
        if (connection != null) connection.close();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <title>Client Dashboard - VeriDedup</title>
    <link rel="stylesheet" href="styles.css">
    
    <style>
        body {
            font-family: 'Poppins', sans-serif;
            background: linear-gradient(to right, #004e92, #000428);
            color: white;
            text-align: center;
        }

        .dashboard-container {
            max-width: 800px;
            margin: 50px auto;
            background: rgba(255, 255, 255, 0.1);
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0px 5px 15px rgba(0, 0, 0, 0.3);
        }

        h2 {
            color: #ff9800;
        }

        .profile-card {
            background: rgba(255, 255, 255, 0.2);
            padding: 20px;
            border-radius: 8px;
            text-align: center;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.2);
        }

        .tab-buttons {
            display: flex;
            justify-content: center;
            gap: 15px;
            margin-top: 20px;
        }

        .tab-buttons button {
            background: #ff9800;
            border: none;
            color: white;
            padding: 12px 20px;
            border-radius: 5px;
            cursor: pointer;
            transition: background 0.3s ease-in-out;
            font-size: 16px;
        }

        .tab-buttons button:hover {
            background: #e68900;
        }

        .upload-message {
            margin-top: 15px;
            padding: 10px;
            background: #ffeb3b;
            color: #333;
            font-weight: bold;
            border-radius: 5px;
            display: inline-block;
        }

        .logout-button {
            margin-top: 15px;
            background: red;
            border: none;
            padding: 10px 15px;
            color: white;
            border-radius: 5px;
            font-size: 16px;
            cursor: pointer;
            transition: background 0.3s ease-in-out;
        }

        .logout-button:hover {
            background: darkred;
        }
    </style>

    <script>
        function navigateTo(page) {
            window.location.href = page;
        }
    </script>

</head>

<body>

    <div class="dashboard-container">
        <h2>Secure File Operations</h2>

        <%-- ✅ Show Upload Message if available --%>
        <% 
            String uploadMessage = (String) session.getAttribute("uploadMessage");
            if (uploadMessage != null) { 
        %>
            <div class="upload-message"><%= uploadMessage %></div>
        <% 
                session.removeAttribute("uploadMessage"); // ✅ Remove message after showing
            } 
        %>

        <div class="profile-card">
            <h3>Client Info</h3>
            <p><strong>Name:</strong> <%= firstName %> <%= lastName %></p>
            <p><strong>Email:</strong> <%= userEmail %></p>
            <p><strong>User Id:</strong> <%= userId %></p>
            <p><strong>Total Files:</strong> <%= totalFiles %></p>
            <p><strong>Storage Used:</strong> <%= formatStorageSize(totalStorageUsed) %></p>
        </div>

        <div class="tab-buttons">
            <button onclick="navigateTo('upload.jsp')">Upload</button>
            <button onclick="navigateTo('verify_integrity.jsp')">Verify Integrity</button>
            <button onclick="navigateTo('download.jsp')">Download</button>
        </div>

        <button class="logout-button" onclick="navigateTo('logout.jsp')">Logout</button>

    </div>

</body>
</html>
