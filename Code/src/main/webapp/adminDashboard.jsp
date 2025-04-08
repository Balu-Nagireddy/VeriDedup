<%@page import="java.sql.*"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="admin_utils.jsp" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Admin Dashboard - VeriDedup</title>
    <link rel="stylesheet" href="styles.css">
    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
    
    <script>
        function switchTab(tabId) {
            document.querySelectorAll('.tab-content').forEach(tab => {
                tab.style.display = "none";
            });
            document.getElementById(tabId).style.display = "block";
        }

        function updateUserStatus(userId, status) {
                fetch('updateUserStatus.jsp', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: new URLSearchParams({ userId: userId, status: status }) // ✅ More reliable format
            })
            .then(response => response.text())
            .then(result => {
                    if (result.trim() === 'success') {
                    alert('User ' + status + ' successfully.');
                    location.reload();
                } else {
                    alert('Failed to update user status: ' + result); // ✅ Show error details
                }
            })
            .catch(error => console.error('Error:', error)); // ✅ Log fetch error
        }


        function revokeUser(userId) {
            if (confirm("Are you sure you want to revoke this user?")) {
                fetch('revoke.jsp', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: 'userId=' + userId
                })
                .then(response => response.text())
                .then(result => {
                    if (result.trim() === 'success') {
                        alert('User revoked successfully.');
                        location.reload();
                    } else {
                        alert('Failed to revoke user.');
                    }
                })
                .catch(error => console.error('Error:', error));
            }
        }
        
    </script>
    
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(to right, #4b6cb7, #182848);
            color: white;
            text-align: center;
        }

        .dashboard-container {
            max-width: 900px;
            margin: 40px auto;
            background: rgba(255, 255, 255, 0.1);
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.2);
        }

        .tab-buttons button {
            background: #0073e6;
            border: none;
            color: white;
            padding: 10px 15px;
            margin: 5px;
            border-radius: 5px;
            cursor: pointer;
            transition: background 0.3s ease-in-out;
        }

        .tab-buttons button:hover {
            background: #005bb5;
        }

        .tab-content {
            display: none;
            margin-top: 20px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            background: white;
            color: black;
            border-radius: 5px;
            overflow: hidden;
            margin-top: 10px;
        }

        table th, table td {
            padding: 10px;
            border: 1px solid #ccc;
        }

        table th {
            background: #0073e6;
            color: white;
        }

        .approve {
            background: #28a745;
            padding: 5px 10px;
            color: white;
            border: none;
            cursor: pointer;
            border-radius: 4px;
        }

        .reject {
            background: #dc3545;
            padding: 5px 10px;
            color: white;
            border: none;
            cursor: pointer;
            border-radius: 4px;
        }

        .revoke {
            background: #ff9800;
            padding: 5px 10px;
            color: white;
            border: none;
            cursor: pointer;
            border-radius: 4px;
        }
    </style>
</head>
<body>
    <div class="dashboard-container">
        <h2>Admin Dashboard</h2>
        <div class="tab-buttons">
            <button onclick="switchTab('pending-users')">Pending Users</button>
            <button onclick="switchTab('approved-users')">Approved Users</button>
            <button onclick="switchTab('audit-logs')">Audit Logs</button>
            <button onclick="switchTab('storage-analytics')">Storage Analytics</button>
            <form action = "logout.jsp">
            	<button>LogOut</button>
            </form>
        </div>

        <div id="pending-users" class="tab-content">
            <h3>Pending Users</h3>
            <table>
                <tr><th>First Name</th><th>Last Name</th><th>Email</th><th>Actions</th></tr>
                <%
                    try (Connection connection = getConnection();
                         PreparedStatement ps = connection.prepareStatement("SELECT id, firstName, lastName, email FROM users WHERE status = 'pending'");
                         ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                %>
                <tr>
                    <td><%= rs.getString("firstName") %></td>
                    <td><%= rs.getString("lastName") %></td>
                    <td><%= rs.getString("email") %></td>
                    <td>
					    <button class="approve" onclick="updateUserStatus(<%= rs.getInt("id") %>, 'approved')">Approve</button>
					    <button class="reject" onclick="updateUserStatus(<%= rs.getInt("id") %>, 'rejected')">Reject</button>
					</td>

                </tr>
                <%
                        }
                    }
                %>
            </table>
        </div>

        <div id="approved-users" class="tab-content">
            <h3>Approved Users</h3>
            <table>
                <tr><th>First Name</th><th>Last Name</th><th>Email</th><th>Actions</th></tr>
                <%
                    try (Connection connection = getConnection();
                         PreparedStatement ps = connection.prepareStatement("SELECT id, firstName, lastName, email FROM users WHERE status = 'approved'");
                         ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                %>
                <tr>
                    <td><%= rs.getString("firstName") %></td>
                    <td><%= rs.getString("lastName") %></td>
                    <td><%= rs.getString("email") %></td>
                    <td>
                        <button class="revoke" onclick="revokeUser(<%= rs.getInt("id") %>)">Revoke</button>
                    </td>
                </tr>
                <%
                        }
                    }
                %>
            </table>
        </div>

        <div id="audit-logs" class="tab-content">
            <h3>System Audit Logs</h3>
            <table>
                <tr><th>Action</th><th>Performed By</th><th>Timestamp</th></tr>
                <%
                    try (Connection connection = getConnection();
                         PreparedStatement ps = connection.prepareStatement("SELECT action, performed_by, timestamp FROM audit_logs ORDER BY timestamp DESC");
                         ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                %>
                <tr>
                    <td><%= rs.getString("action") %></td>
                    <td><%= rs.getString("performed_by") %></td>
                    <td><%= rs.getTimestamp("timestamp") %></td>
                </tr>
                <%
                        }
                    }
                %>
            </table>
        </div>
    </div>
    <footer>
	    <p>© 2025 VeriDedup | Secure Data Deduplication</p>
	</footer>
</body>
</html>
