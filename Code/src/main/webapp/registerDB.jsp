<%@ page import="java.sql.DriverManager" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.Connection" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Register Database</title>
    <script type="text/javascript">
        function redirectToWelcome() {
            window.location.href = "welcome.jsp";
        }
    </script>
</head>
<body>
    <%
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String dob = request.getParameter("dob");
        String mobile = request.getParameter("mobile");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String gender = request.getParameter("gender");

        Connection connection = null;
        PreparedStatement ps = null;

        try {
            // Load the MySQL JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver"); // Ensure this matches your MySQL Connector/J version

            // Establish the connection
            connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/VeriDedup", "root", "Rgukt143");

            // Prepare the SQL insert statement
            String sql = "INSERT INTO users (firstName, lastName, dob, mobile, email, password, gender, status) VALUES (?, ?, ?, ?, ?, ?, ?, 'pending')";
            ps = connection.prepareStatement(sql);
            ps.setString(1, firstName);
            ps.setString(2, lastName);
            ps.setString(3, dob);
            ps.setString(4, mobile);
            ps.setString(5, email);
            ps.setString(6, password);
            ps.setString(7, gender);

            // Execute the insert
            int rowValues = ps.executeUpdate();
            if (rowValues > 0) {
                out.println("<script type='text/javascript'>");
                out.println("alert('Registration Successful! Waiting for admin approval.');");
                out.println("redirectToWelcome();");
                out.println("</script>");
            } else {
                out.println("Registration Failed. Please try again.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.println("An error occurred during registration: " + e.getMessage());
        } finally {
            // Close the resources
            try {
                if (ps != null) {
                    ps.close();
                }
                if (connection != null) {
                    connection.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    %>
</body>
</html>
