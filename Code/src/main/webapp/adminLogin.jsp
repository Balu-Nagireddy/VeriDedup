<%@ page import="java.sql.DriverManager" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    String email = request.getParameter("email");
    String password = request.getParameter("password");
    String captchaInput = request.getParameter("captcha");

    Connection connection = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        // Load the MySQL JDBC driver
        Class.forName("com.mysql.cj.jdbc.Driver");

        // Establish the connection
        connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/VeriDedup", "root", "Rgukt143");

        // Check CAPTCHA
        String captchaSession = (String) session.getAttribute("captcha");
        if (captchaInput == null || !captchaInput.equals(captchaSession)) {
            session.setAttribute("errorMessage", "Captcha does not match.");
            response.sendRedirect("admin.jsp");
            return;
        }

        // Prepare the SQL query for admin credentials
        String sql = "SELECT password FROM admin WHERE email = ?";
        ps = connection.prepareStatement(sql);
        ps.setString(1, email);

        // Execute the query
        rs = ps.executeQuery();

        if (rs.next()) {
            String pass = rs.getString("password");

            if (password.equals(pass)) {
                // If credentials are valid, redirect to admin dashboard
                session.setAttribute("adminEmail", email);
                response.sendRedirect("adminDashboard.jsp");
            } else {
                // Invalid password, redirect to admin.jsp with error message
                session.setAttribute("errorMessage", "Invalid email or password.");
                response.sendRedirect("admin.jsp");
            }
        } else {
            // Email not found, redirect to admin.jsp with error message
            session.setAttribute("errorMessage", "Invalid email or password.");
            response.sendRedirect("admin.jsp");
        }
    } catch (Exception e) {
        e.printStackTrace();
        session.setAttribute("errorMessage", "An error occurred during login: " + e.getMessage());
        response.sendRedirect("admin.jsp");
    } finally {
        // Close the resources
        try {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (connection != null) connection.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>
