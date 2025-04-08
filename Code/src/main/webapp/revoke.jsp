<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="admin_utils.jsp" %> 

<%
    int userId = Integer.parseInt(request.getParameter("userId"));

    Connection connection = null;
    PreparedStatement ps = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/VeriDedup", "root", "Rgukt143");

        String deleteSQL = "DELETE FROM users WHERE id = ?";
        ps = connection.prepareStatement(deleteSQL);
        ps.setInt(1, userId);
        int rowsAffected = ps.executeUpdate();

        if (rowsAffected > 0) {
            logAdminAction("Revoked & Deleted User (ID: " + userId + ")", "Admin");
            out.print("success");
        } else {
            out.print("failure");
        }
    } finally {
        if (ps != null) ps.close();
        if (connection != null) connection.close();
    }
%>
