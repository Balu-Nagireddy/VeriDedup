<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, javax.servlet.http.*, javax.servlet.*" %>
<%@ page import="java.util.*" %>

<%
    // Session validation
    HttpSession sessionUser = request.getSession(false);
    if (sessionUser == null || sessionUser.getAttribute("CSPEmail") == null) {
        response.sendRedirect("host.jsp?error=UnauthorizedAccess");
        return;
    }

    // Host details
    String hostEmail = (String) sessionUser.getAttribute("CSPEmail");
    String hostName = (String) sessionUser.getAttribute("CSPName"); 

    // Database credentials
    String dbURL = "jdbc:mysql://localhost:3306/veridedup";
    String dbUser = "root";
    String dbPass = "Rgukt143";

    Connection connection = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    long totalStorage = 5L * 1024 * 1024 * 1024; // 5 GB in bytes
    long usedStorage = 0;
    int totalLogs = 0;

    String usersTable = "", adminsTable = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        connection = DriverManager.getConnection(dbURL, dbUser, dbPass);

        // Fetch Users Data with Storage Used
        ps = connection.prepareStatement(
            "SELECT u.id, u.firstName, u.lastName, u.email, u.status, u.created_at, " +
            "(SELECT COALESCE(SUM(f.file_size), 0) FROM files f WHERE f.user_id = u.id) AS storage_used " +
            "FROM users u"
        );
        rs = ps.executeQuery();
        while (rs.next()) {
            long userStorageUsed = rs.getLong("storage_used");
            usersTable += "<tr>" +
                          "<td>" + rs.getInt("id") + "</td>" +
                          "<td><a href='clientDetails.jsp?userId=" + rs.getInt("id") + "'>" + rs.getString("firstName") + " " + rs.getString("lastName") + "</a></td>" +
                          "<td>" + rs.getString("email") + "</td>" +
                          "<td>" + rs.getString("status") + "</td>" +
                          "<td>" + userStorageUsed / (1024 * 1024) + " MB</td>" + 
                          "<td>" + rs.getString("created_at") + "</td></tr>";
        }
        rs.close(); ps.close();

        // Fetch Admins Data
        ps = connection.prepareStatement("SELECT id, firstName, lastName, email, created_at FROM admin");
        rs = ps.executeQuery();
        while (rs.next()) {
            adminsTable += "<tr><td>" + rs.getInt("id") + "</td><td>" + rs.getString("firstName") + " " + rs.getString("lastName") +
                           "</td><td>" + rs.getString("email") + "</td><td>" + rs.getString("created_at") + "</td></tr>";
        }
        rs.close(); ps.close();

        // Fetch Total Used Storage
        ps = connection.prepareStatement("SELECT COALESCE(SUM(file_size), 0) AS total_used FROM files");
        rs = ps.executeQuery();
        if (rs.next()) {
            usedStorage = rs.getLong("total_used");
        }
        rs.close(); ps.close();

        // Fetch Audit Log Count
        ps = connection.prepareStatement("SELECT COUNT(*) AS log_count FROM audit_logs");
        rs = ps.executeQuery();
        if (rs.next()) {
            totalLogs = rs.getInt("log_count");
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
    <title>CSP Dashboard | VeriDedup</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body { background-color: #f4f6f9; }
        .dashboard-container { padding: 20px; }
        .card { border-radius: 12px; transition: 0.3s; padding: 20px; text-align: center; }
        .chart-container { width: 100%; max-width: 500px; margin: auto; }
        .logout-btn { position: absolute; top: 20px; right: 20px; }
        .table-container { display: none; max-height: 350px; overflow-y: auto; }
        .toggle-btn { cursor: pointer; font-weight: bold; padding: 10px; border-radius: 5px; background-color: #0056b3; color: white; }
        .footer{text-align: center;}
    </style>
</head>
<body>

<div class="container dashboard-container">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
	        🔹 <strong>Host:</strong> <%= hostName %> <br>
	        📧 <strong>Email:</strong> <%= hostEmail %>
        </div>
        <a href="logout.jsp" class="btn btn-danger logout-btn">Logout</a>
    </div>

    <h2 class="text-center text-primary mb-4">CSP Dashboard - VeriDedup</h2>

    <div class="row g-4">
        <div class="col-md-6">
            <div class="card">
                <h4>Storage Usage</h4>
                <div class="chart-container">
                    <canvas id="storageChart"></canvas>
                </div>
            </div>
        </div>

        <div class="col-md-6">
            <div class="card">
                <h4>Audit Log Activity</h4>
                <div class="chart-container">
                    <canvas id="auditChart"></canvas>
                </div>
            </div>
        </div>
    </div>

    <div class="mt-4">
        <div class="toggle-btn" onclick="toggleTable('usersTable')">Manage Users ⬇️</div>
        <div id="usersTable" class="table-container">
            <table class="table table-striped">
                <thead>
                    <tr><th>ID</th><th>Name</th><th>Email</th><th>Status</th><th>Storage Used</th><th>Time Stamp</th></tr>
                </thead>
                <tbody><%= usersTable %></tbody>
            </table>
        </div>
    </div>
</div>

<script>
    function toggleTable(tableId) {
        let table = document.getElementById(tableId);
        table.style.display = table.style.display === "none" ? "block" : "none";
    }

    let usedStorage = <%= usedStorage %>;
    let totalStorage = <%= totalStorage %>;

    let storageChart = new Chart(document.getElementById("storageChart"), {
        type: "doughnut",
        data: {
            labels: ["Used Storage", "Free Storage"],
            datasets: [{
                data: [usedStorage, totalStorage - usedStorage],
                backgroundColor: ["#ff4757", "#2ed573"],
            }]
        }
    });

    let auditChart = new Chart(document.getElementById("auditChart"), {
        type: "bar",
        data: {
            labels: ["Total Audit Logs"],
            datasets: [{
                label: "Log Entries",
                data: [<%= totalLogs %>],
                backgroundColor: "#1e90ff",
            }]
        }
    });
</script>

<footer class="footer"><p>© 2025 VeriDedup | Secure Data Deduplication</p></footer>

</body>
</html>
