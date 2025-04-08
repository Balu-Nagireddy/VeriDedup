<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="admin_utils.jsp" %>

<%
    String userIdParam = request.getParameter("userId");
    String status = request.getParameter("status");

    if (userIdParam == null || status == null || userIdParam.isEmpty() || status.isEmpty()) {
        out.print("failure - Invalid parameters");
        return;
    }

    int userId;
    try {
        userId = Integer.parseInt(userIdParam);
    } catch (NumberFormatException e) {
        out.print("failure - Invalid user ID format");
        return;
    }

    Connection connection = null;
    PreparedStatement ps = null;

    try {
        // ✅ Load MySQL JDBC Driver
        Class.forName("com.mysql.cj.jdbc.Driver");

        // ✅ Establish Database Connection
        connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/VeriDedup", "root", "Rgukt143");

        int rowsAffected = 0;
        String actionLog = "";

        if ("rejected".equalsIgnoreCase(status)) {
            // 🚨 DELETE USER IF REJECTED
            String deleteSQL = "DELETE FROM users WHERE id = ?";
            ps = connection.prepareStatement(deleteSQL);
            ps.setInt(1, userId);
            rowsAffected = ps.executeUpdate();
            System.out.println("DEBUG: Delete query executed, rowsAffected: " + rowsAffected);
            
            if (rowsAffected > 0) {
                actionLog = "Rejected & Deleted User (ID: " + userId + ")";
            }
        } else {
            // ✅ UPDATE USER STATUS
            String updateSQL = "UPDATE users SET status = ? WHERE id = ?";
            ps = connection.prepareStatement(updateSQL);
            ps.setString(1, status);
            ps.setInt(2, userId);
            rowsAffected = ps.executeUpdate();
            System.out.println("DEBUG: Update query executed, rowsAffected: " + rowsAffected);

            if (rowsAffected > 0) {
                actionLog = "Updated User (ID: " + userId + ") status to " + status;
            }
        }

        if (rowsAffected > 0) {
            logAdminAction(actionLog, "Admin");
            out.print("success");
        } else {
            System.out.println("DEBUG: No rows affected! User may not exist.");
            out.print("failure - No rows affected");
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.print("failure - Exception: " + e.getMessage());
    } finally {
        try {
            if (ps != null) ps.close();
            if (connection != null) connection.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>
