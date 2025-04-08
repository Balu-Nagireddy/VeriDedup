<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*" %>

<%
    // ✅ Check session authentication
    HttpSession sessionUser = request.getSession(false);
    if (sessionUser == null || sessionUser.getAttribute("CSPEmail") == null) {
        response.sendRedirect("host.jsp?error=UnauthorizedAccess");
        return;
    }

    // ✅ Fetch user ID from request
    String userIdParam = request.getParameter("userId");
    if (userIdParam == null || userIdParam.isEmpty()) {
        response.sendRedirect("host_dashboard.jsp?error=InvalidUser");
        return;
    }
    int userId = Integer.parseInt(userIdParam);

    // ✅ Database credentials
    String dbURL = "jdbc:mysql://localhost:3306/veridedup";
    String dbUser = "root";
    String dbPass = "Rgukt143";

    Connection connection = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    String fullName = "", email = "", status = "";
    long usedStorage = 0, maxStorage = 500L * 1024 * 1024; // 500MB limit

    List<Map<String, String>> filesList = new ArrayList<>();

    try {
        // ✅ Load MySQL driver and connect to DB
        Class.forName("com.mysql.cj.jdbc.Driver");
        connection = DriverManager.getConnection(dbURL, dbUser, dbPass);

        // ✅ Get client details
        ps = connection.prepareStatement("SELECT firstName, lastName, email, status FROM users WHERE id = ?");
        ps.setInt(1, userId);
        rs = ps.executeQuery();
        if (rs.next()) {
            fullName = rs.getString("firstName") + " " + rs.getString("lastName");
            email = rs.getString("email");
            status = rs.getString("status");
        }
        rs.close(); ps.close();

        // ✅ Get total storage used by the client
        ps = connection.prepareStatement("SELECT COALESCE(SUM(file_size), 0) AS total_used FROM files WHERE user_id = ?");
        ps.setInt(1, userId);
        rs = ps.executeQuery();
        if (rs.next()) {
            usedStorage = rs.getLong("total_used");
        }
        rs.close(); ps.close();

        // ✅ Fetch all files uploaded by the client
        ps = connection.prepareStatement("SELECT id, file_name, file_size, upload_timestamp FROM files WHERE user_id = ?");
        ps.setInt(1, userId);
        rs = ps.executeQuery();
        while (rs.next()) {
            Map<String, String> fileData = new HashMap<>();
            fileData.put("id", rs.getString("id"));
            fileData.put("name", rs.getString("file_name"));
            fileData.put("size", rs.getLong("file_size") / (1024 * 1024) + " MB");
            fileData.put("uploadTime", rs.getString("upload_timestamp"));
            filesList.add(fileData);
        }
        rs.close(); ps.close();

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (connection != null) connection.close();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Client Details | VeriDedup</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body { background-color: #f4f6f9; }
        .container { max-width: 900px; margin-top: 30px; }
        .card { border-radius: 12px; padding: 20px; margin-bottom: 20px; }
        .chart-container { width: 100%; max-width: 400px; margin: auto; }
        .file-actions { display: flex; gap: 10px; }
        .status-badge { padding: 5px 10px; border-radius: 5px; font-weight: bold; }
        .active { background-color: #28a745; color: white; }
        .inactive { background-color: #dc3545; color: white; }
    </style>
</head>
<body>

<div class="container">
    <a href="host_dashboard.jsp" class="btn btn-secondary mb-3">⬅ Back to Dashboard</a>
    <h2 class="text-center text-primary">Client Details</h2>

    <div class="card">
	    <div>
	        <h4>📌 Client Info</h4>
	        <p><strong>User ID:</strong> <%= userId %></p>
	        <p><strong>Name:</strong> <%= fullName %></p>
	        <p><strong>Email:</strong> <%= email %></p>
	        <p><strong>Status:</strong> 
	            <span class="status-badge <%= status.equals("Active") ? "active" : "inactive" %>">
	                <%= status %>
	            </span>
	        </p>
	    </div>
	
	    <!-- Upload Button Positioned at the Right -->
	    <div class="upload-section">
	        <button class="btn btn-warning" onclick="scrollToUpload()">📤 Upload</button>
	    </div>
	</div>
	
	<script>
		function showUploadAlert() {
	        let fileInput = document.getElementById("fileInput");
	        if (fileInput.files.length === 0) {
	            alert("⚠ Please select a file before uploading.");
	        } else {
	            alert("⚠ Data Uploading is not Possible Due to Deduplication Policy.");
	        }
	    }
	    function scrollToUpload() {
	        document.getElementById("uploadSection").scrollIntoView({ behavior: "smooth" });
	    }
	</script>
	
	<style>
	    .upload-section {
	        margin-left: auto; /* Pushes the button to the right */
	        
	    }
	</style>


    <div class="card">
        <h4>📊 Storage Usage</h4>
        <div class="chart-container">
            <canvas id="storageChart"></canvas>
        </div>
    </div>

    <div class="card">
        <h4>📂 Uploaded & Existing Files</h4>
        <% if (filesList.isEmpty()) { %>
            <p>No files available.</p>
        <% } else { %>
            <table class="table table-striped">
                <thead>
                    <tr>
                        <th>File Name</th>
                        <th>Size</th>
                        <th>Uploaded At</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Map<String, String> file : filesList) { %>
                        <tr>
                            <td><%= file.get("name") %></td>
                            <td><%= file.get("size") %></td>
                            <td><%= file.get("uploadTime") %></td>
                            <td class="file-actions">
                                <a href="downloadFile.jsp?fileId=<%= file.get("id") %>" class="btn btn-success btn-sm">Download</a>
                                <a href="deleteFile.jsp?fileName=<%= file.get("name") %>" class="btn btn-danger btn-sm">Delete</a>
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        <% } %>
    </div>

    <!-- 🚀 Upload New File Section -->
	<div id="uploadSection" class="card">
	    <h4>📤 Upload New File</h4>
	    <form id="uploadForm">
	        <input type="file" class="form-control mb-2" id="fileInput">
	        <button type="button" class="btn btn-primary" onclick="showUploadAlert()">Upload File</button>
	    </form>
	</div>
</div>

<script>
    let usedStorage = <%= usedStorage %>;
    let maxStorage = <%= maxStorage %>;

    let storageChart = new Chart(document.getElementById("storageChart"), {
        type: "doughnut",
        data: {
            labels: ["Used Storage", "Free Storage"],
            datasets: [{
                data: [usedStorage, maxStorage - usedStorage],
                backgroundColor: ["#ff4757", "#2ed573"],
            }]
        }
    });
</script>

</body>
</html>
