<%@ page import="java.sql.*, javax.servlet.http.HttpSession" %>
<%
    String email = request.getParameter("email");
    String password = request.getParameter("password");
    String captchaInput = request.getParameter("captcha");

    // ✅ Use built-in `session` object directly
    String captchaSession = (String) session.getAttribute("captcha");
    session.removeAttribute("captcha"); // ❌ Prevent CAPTCHA reuse

    // ✅ CAPTCHA Validation
    if (captchaInput == null || !captchaInput.equals(captchaSession)) {
        response.sendRedirect("host.jsp?error=InvalidCaptcha");
        return;
    }

    try {
        // ✅ Database Connection
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/VeriDedup", "root", "Rgukt143");

        // ✅ Corrected SQL Query (`email` & `password` fields)
        String query = "SELECT * FROM host WHERE email = ? AND password = ?";
        PreparedStatement ps = connection.prepareStatement(query);
        ps.setString(1, email);
        ps.setString(2, password);
        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            // ✅ Successful Login → Set Session Attributes
            session.setAttribute("CSPLoggedIn", true);
            session.setAttribute("CSPEmail", email);
            session.setAttribute("CSPName", rs.getString("username")); // Store Host Name
            response.sendRedirect("host_dashboard.jsp");
        } else {
            // ❌ Invalid Credentials
            response.sendRedirect("host.jsp?error=InvalidCredentials");
        }

        // ✅ Close Resources
        rs.close();
        ps.close();
        connection.close();
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("host.jsp?error=ServerError");
    }
%>
