<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Verify File Integrity - VeriDedup</title>
    <link rel="stylesheet" href="styles.css">
    
    <script>
        function filterByDate() {
            let selectedDate = document.getElementById("dateFilter").value;
            let rows = document.querySelectorAll(".file-row");
            
            rows.forEach(row => {
                let fileDate = row.getAttribute("data-date").split(" ")[0]; // Extract only date (YYYY-MM-DD)
                if (selectedDate === "" || fileDate === selectedDate) {
                    row.style.display = "";
                } else {
                    row.style.display = "none";
                }
            });
        }

        function filterByName() {
            let searchText = document.getElementById("nameFilter").value.toLowerCase();
            let rows = document.querySelectorAll(".file-row");

            rows.forEach(row => {
                let fileName = row.getAttribute("data-name").toLowerCase();
                if (searchText === "" || fileName.includes(searchText)) {
                    row.style.display = "";
                } else {
                    row.style.display = "none";
                }
            });
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

        .container {
            max-width: 900px;
            margin: 30px auto;
            background: rgba(255, 255, 255, 0.1);
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0px 5px 15px rgba(0, 0, 0, 0.3);
        }

        h2 {
            color: #ff9800;
        }

        input, select {
            padding: 10px;
            width: 80%;
            margin: 10px 0;
            border: 1px solid #ccc;
            border-radius: 5px;
            font-size: 16px;
        }

        button {
            background: #ff9800;
            border: none;
            color: white;
            padding: 10px;
            border-radius: 5px;
            cursor: pointer;
            transition: background 0.3s ease-in-out;
            font-size: 16px;
        }

        button:hover {
            background: #e68900;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            background: white;
            color: black;
            margin-top: 20px;
            border-radius: 5px;
            overflow: hidden;
        }

        th, td {
            padding: 12px;
            border: 1px solid #ddd;
        }

        th {
            background: #0073e6;
            color: white;
        }

        .back-link {
            display: block;
            margin-top: 20px;
            text-decoration: none;
            color: #ff9800;
            font-weight: bold;
        }

        .back-link:hover {
            color: #e68900;
        }
    </style>
</head>
<body>

    <div class="container">
        <h2>🔍 Verify File Integrity</h2>

        <form method="post">
            <input type="text" name="userId" placeholder="Enter Your User ID" required>
            <button type="submit">Search Files</button>
        </form>

        <br>
        
        <%
            String userId = request.getParameter("userId");
            if (userId != null && !userId.isEmpty()) {
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/VeriDedup", "root", "Rgukt143");

                    // ✅ Retrieve files and verification tag from the verification_tags table
                    String query = "SELECT f.id, f.file_name, f.upload_timestamp, v.verification_tag " +
                                   "FROM files f LEFT JOIN verification_tags v ON f.id = v.file_id " +
                                   "WHERE f.user_id = ? ORDER BY f.upload_timestamp DESC";
                    PreparedStatement ps = connection.prepareStatement(query);
                    ps.setString(1, userId);
                    ResultSet rs = ps.executeQuery();

                    if (rs.isBeforeFirst()) { // Check if results exist
        %>
        <label for="dateFilter">📅 Filter by Date:</label>
        <input type="date" id="dateFilter" onchange="filterByDate()">

        <label for="nameFilter">🔍 Search by Name:</label>
        <input type="text" id="nameFilter" placeholder="Enter file name..." onkeyup="filterByName()">

        <table>
            <tr>
                <th>File Name</th>
                <th>Upload Timestamp</th>
                <th>Verification Tag</th>
                <th>Verification Status</th>
            </tr>
            <%
                    while (rs.next()) {
                        String fileName = rs.getString("file_name");
                        String uploadTimestamp = rs.getString("upload_timestamp"); // ✅ Fetch correct timestamp
                        String verificationTag = rs.getString("verification_tag");
            %>
            <tr class="file-row" data-date="<%= uploadTimestamp %>" data-name="<%= fileName %>">
                <td><%= fileName %></td>
                <td><%= uploadTimestamp %></td> <!-- ✅ Show proper timestamp -->
                <td><%= (verificationTag != null) ? verificationTag : "N/A" %></td>
                <td>
                    <%
                        if (verificationTag != null) {
                            out.println("<span style='color:green;'>✔ Verified</span>");
                        } else {
                            out.println("<span style='color:red;'>❌ Not Verified</span>");
                        }
                    %>
                </td>
            </tr>
            <%
                    }
            %>
        </table>
        <%
                    } else {
                        out.println("<p>No files found for the given User ID.</p>");
                    }

                    rs.close();
                    ps.close();
                    connection.close();
                } catch (Exception e) {
                    e.printStackTrace();
                    out.println("<p>Error retrieving files: " + e.getMessage() + "</p>");
                }
            }
        %>

        <a href="client_dashboard.jsp" class="back-link">⬅ Back to Dashboard</a>
    </div>

    <footer>
        <p>© 2025 VeriDedup | Secure Data Deduplication</p>
    </footer>

</body>
</html>
