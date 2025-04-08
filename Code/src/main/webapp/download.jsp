<%@ page import="java.sql.*, javax.servlet.http.HttpSession" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Download Files - VeriDedup</title>
    <link rel="stylesheet" href="styles.css">
    
    <script>
        function decryptAndDownload(fileId) {
            window.location.href = "DecryptFileServlet?fileId=" + fileId;
        }

        function toggleDarkMode() {
            document.body.classList.toggle("dark-mode");
        }

        function filterFiles() {
            let nameFilter = document.getElementById("nameFilter").value.toLowerCase();
            let dateFilter = document.getElementById("dateFilter").value;
            let sizeFilter = document.getElementById("sizeFilter").value;
            let rows = document.querySelectorAll(".file-row");

            rows.forEach(row => {
                let fileName = row.getAttribute("data-name").toLowerCase();
                let fileDate = row.getAttribute("data-date").split(" ")[0];
                let fileSize = parseFloat(row.getAttribute("data-size"));

                let nameMatch = nameFilter === "" || fileName.includes(nameFilter);
                let dateMatch = dateFilter === "" || fileDate === dateFilter;
                let sizeMatch = sizeFilter === "" || (fileSize <= parseFloat(sizeFilter));

                row.style.display = nameMatch && dateMatch && sizeMatch ? "" : "none";
            });
        }
    </script>

    <style>
        /* General Styling */
        body {
            font-family: 'Poppins', sans-serif;
            background: linear-gradient(to right, #eef2f3, #8e9eab);
            color: #333;
            text-align: center;
            transition: background 0.3s ease-in-out, color 0.3s ease-in-out;
        }

        /* Dark Mode */
        body.dark-mode {
            background: #121212;
            color: #f4f4f4;
        }

        .container {
            max-width: 900px;
            margin: 40px auto;
            background: white;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0px 10px 20px rgba(0, 0, 0, 0.15);
            transition: transform 0.3s ease-in-out;
        }

        .container:hover {
            transform: scale(1.02);
        }

        h2 {
            color: #0073e6;
            font-size: 24px;
            margin-bottom: 20px;
        }

        /* Filters */
        .filters {
            display: flex;
            justify-content: center;
            gap: 15px;
            flex-wrap: wrap;
            margin-bottom: 20px;
        }

        input, select {
            padding: 10px;
            width: 200px;
            border: 1px solid #ccc;
            border-radius: 5px;
            font-size: 16px;
        }

        /* Dark Mode Button */
        .dark-mode-toggle {
            position: absolute;
            top: 20px;
            right: 20px;
            background: #0073e6;
            color: white;
            border: none;
            padding: 8px 12px;
            border-radius: 5px;
            cursor: pointer;
            transition: background 0.3s ease-in-out;
        }

        .dark-mode-toggle:hover {
            background: #005bb5;
        }

        /* Table Styling */
        table {
            width: 100%;
            border-collapse: collapse;
            background: white;
            color: black;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0px 5px 15px rgba(0, 0, 0, 0.2);
            margin-top: 20px;
        }

        th, td {
            padding: 12px;
            border: 1px solid #ddd;
            text-align: center;
        }

        th {
            background: #0073e6;
            color: white;
            transition: background 0.3s ease-in-out;
        }

        tr:hover {
            background: #f5f5f5;
            transition: background 0.2s ease-in-out;
        }

        /* Decrypt Button */
        .decrypt-btn {
            background: #ff9800;
            border: none;
            color: white;
            padding: 10px 15px;
            border-radius: 5px;
            cursor: pointer;
            transition: background 0.3s ease-in-out, transform 0.2s ease-in-out;
            font-size: 14px;
        }

        .decrypt-btn:hover {
            background: #e68900;
            transform: scale(1.05);
        }

        /* Back Link */
        .back-link {
            display: block;
            margin-top: 20px;
            text-decoration: none;
            color: #0073e6;
            font-weight: bold;
            transition: color 0.3s ease-in-out;
        }

        .back-link:hover {
            color: #005bb5;
        }
    </style>
</head>
<body>

    <button class="dark-mode-toggle" onclick="toggleDarkMode()">🌙 Dark Mode</button>

    <div class="container">
        <h2>🔽 Download Your Encrypted Files</h2>

        <div class="filters">
            <input type="text" id="nameFilter" placeholder="🔍 Search by Name" onkeyup="filterFiles()">
            <input type="date" id="dateFilter" onchange="filterFiles()">
            <input type="number" id="sizeFilter" placeholder="📏 Max Size (MB)" onkeyup="filterFiles()">
        </div>

        <%
            HttpSession userSession = request.getSession(false);
            if (userSession == null || userSession.getAttribute("Email") == null) {
                response.sendRedirect("client.jsp?error=SessionExpired");
                return;
            }

            int userId = (int) userSession.getAttribute("id");

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/VeriDedup", "root", "Rgukt143");

                String query = "SELECT f.id, f.file_name, f.upload_timestamp, f.file_size, vt.verification_tag " +
                               "FROM files f " +
                               "LEFT JOIN verification_tags vt ON f.id = vt.file_id " + 
                               "WHERE f.user_id = ? ORDER BY f.upload_timestamp DESC";
                PreparedStatement ps = connection.prepareStatement(query);
                ps.setInt(1, userId);
                ResultSet rs = ps.executeQuery();

                if (rs.isBeforeFirst()) {
        %>
        <table>
            <tr>
                <th>File Name</th>
                <th>Upload Date</th>
                <th>File Size (MB)</th>
                <th>Integrity Status</th>
                <th>Action</th>
            </tr>
            <%
                    while (rs.next()) {
                        int fileId = rs.getInt("id");
                        String fileName = rs.getString("file_name");
                        String uploadTimestamp = rs.getString("upload_timestamp");
                        double fileSize = rs.getDouble("file_size");
                        String verificationTag = rs.getString("verification_tag");
            %>
            <tr class="file-row" data-name="<%= fileName %>" data-date="<%= uploadTimestamp %>" data-size="<%= fileSize %>">
                <td><%= fileName %></td>
                <td><%= uploadTimestamp %></td>
                <td><%= fileSize %> MB</td>
                <td>
                    <%= verificationTag != null ? "<span style='color:green;'>✔ Verified</span>" : "<span style='color:red;'>❌ Not Verified</span>" %>
                </td>
                <td>
                    <button class="decrypt-btn" onclick="decryptAndDownload('<%= fileId %>')">🔓 Decrypt & Download</button>
                </td>
            </tr>
            <%
                    }
            %>
        </table>
        <%
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        %>

        <a href="client_dashboard.jsp" class="back-link">⬅ Back to Dashboard</a>
    </div>
</body>
</html>
