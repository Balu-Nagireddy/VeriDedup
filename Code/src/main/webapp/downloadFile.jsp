<%@ page language="java" import="java.io.*, java.sql.*, javax.servlet.*, javax.servlet.http.*" %>

<%
    // ✅ Check session authentication (only logged-in users can download files)
    HttpSession sessionUser = request.getSession(false);
    if (sessionUser == null || sessionUser.getAttribute("CSPEmail") == null) {
        response.sendRedirect("clientDetails.jsp?error=UnauthorizedAccess");
        return;
    }

    // ✅ Get file ID from request
    String fileIdParam = request.getParameter("fileId");
    if (fileIdParam == null || fileIdParam.isEmpty()) {
        response.sendRedirect("clientDetails.jsp?error=InvalidFile");
        return;
    }
    int fileId = Integer.parseInt(fileIdParam);

    // ✅ Database credentials
    String dbURL = "jdbc:mysql://localhost:3306/veridedup";
    String dbUser = "root";
    String dbPass = "Rgukt143";

    Connection connection = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    InputStream fileStream = null;
    String fileName = "";

    try {
        // ✅ Load MySQL driver and establish connection
        Class.forName("com.mysql.cj.jdbc.Driver");
        connection = DriverManager.getConnection(dbURL, dbUser, dbPass);

        // ✅ Fetch encrypted file from database
        ps = connection.prepareStatement("SELECT file_name, file_data FROM files WHERE id = ?");
        ps.setInt(1, fileId);
        rs = ps.executeQuery();

        if (rs.next()) {
            fileName = rs.getString("file_name");
            fileStream = rs.getBinaryStream("file_data"); // Fetch encrypted file data
        } else {
            response.sendRedirect("clientDetails.jsp?error=FileNotFound");
            return;
        }
        
        // ✅ Set response headers for file download (Force download in encrypted format)
        response.setContentType("application/octet-stream");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + ".enc\"");

        // ✅ Write encrypted data to response output stream
        OutputStream outStream = response.getOutputStream();
        byte[] buffer = new byte[4096];
        int bytesRead;
        while ((bytesRead = fileStream.read(buffer)) != -1) {
            outStream.write(buffer, 0, bytesRead);
        }

        // ✅ Close resources
        fileStream.close();
        outStream.flush();
        outStream.close();

    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("clientDetails.jsp?error=DownloadError");
    } finally {
        if (rs != null) rs.close();
        if (ps != null) ps.close();
        if (connection != null) connection.close();
    }
%>
