<%@ page import="java.sql.*, javax.servlet.http.HttpSession" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    String email = request.getParameter("email");
    String password = request.getParameter("password");
    String captchaInput = request.getParameter("captcha");

    Connection connection = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/VeriDedup", "root", "Rgukt143");

        // CAPTCHA Validation
        String captchaSession = (String) session.getAttribute("captcha");
        session.removeAttribute("captcha"); // Remove to prevent reuse
        if (captchaInput == null || !captchaInput.equals(captchaSession)) {
            session.setAttribute("error", "Captcha does not match.");
            response.sendRedirect("client.jsp");
            return;
        }

        // Fetch user credentials and status
        String sql = "SELECT password, firstName, lastName, id, status FROM users WHERE email = ?";
        ps = connection.prepareStatement(sql);
        ps.setString(1, email);
        rs = ps.executeQuery();

        if (rs.next()) {
            String dbPassword = rs.getString("password"); // Get stored password (plaintext)
            String status = rs.getString("status"); // Get user status

            if (!"approved".equalsIgnoreCase(status)) { // Check if user is approved
                session.setAttribute("error", "Your account is not approved. Please contact the admin.");
                response.sendRedirect("client.jsp");
                return;
            }

            if (password.equals(dbPassword)) { // ✅ Direct password comparison
                // ✅ Successful Login → Set session attributes
                HttpSession userSession = request.getSession();
                userSession.setAttribute("Email", email);
                userSession.setAttribute("FirstName", rs.getString("firstName"));
                userSession.setAttribute("LastName", rs.getString("lastName"));
                userSession.setAttribute("id", rs.getObject("id"));

                response.sendRedirect("client_dashboard.jsp");
            } else {
                session.setAttribute("error", "Invalid email or password.");
                response.sendRedirect("client.jsp");
            }
        } else {
            session.setAttribute("error", "Invalid email or password.");
            response.sendRedirect("client.jsp");
        }
    } catch (Exception e) {
        e.printStackTrace();
        session.setAttribute("error", "An error occurred. Please try again.");
        response.sendRedirect("client.jsp");
    } finally {
        if (rs != null) rs.close();
        if (ps != null) ps.close();
        if (connection != null) connection.close();
    }
%>
