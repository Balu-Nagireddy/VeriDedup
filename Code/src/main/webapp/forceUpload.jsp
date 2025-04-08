<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.*, javax.servlet.*" %>

<%
    // Retrieve parameters from request
    String fileName = request.getParameter("fileName");
    String fileHash = request.getParameter("fileHash");
    String userId = (String) session.getAttribute("userId");

    // If parameters are missing, redirect back
    if (fileName == null || fileHash == null || userId == null) {
        response.sendRedirect("client_dashboard.jsp?error=missingParameters");
        return;
    }
%>

<html>
<head>
    <title>Duplicate File Detected</title>
    <link rel="stylesheet" type="text/css" href="styles.css">
    <script>
        function overwriteFile() {
            document.getElementById("uploadForm").action = "OverwriteFileServlet";
            document.getElementById("uploadForm").submit();
        }

        function renameFile() {
            let newName = prompt("Enter a new filename:");
            if (newName) {
                document.getElementById("newFileName").value = newName;
                document.getElementById("uploadForm").action = "RenameFileServlet";
                document.getElementById("uploadForm").submit();
            }
        }
    </script>
</head>
<body>
    <div class="container">
        <h2>Duplicate File Found</h2>
        <p>A file with the name "<strong><%= fileName %></strong>" already exists.</p>
        <p>Do you want to overwrite it or rename the new file?</p>

        <form id="uploadForm" method="post">
            <input type="hidden" name="fileName" value="<%= fileName %>">
            <input type="hidden" name="fileHash" value="<%= fileHash %>">
            <input type="hidden" name="userId" value="<%= userId %>">
            <input type="hidden" id="newFileName" name="newFileName">

            <button type="button" onclick="overwriteFile()">Overwrite File</button>
            <button type="button" onclick="renameFile()">Rename & Upload</button>
            <a href="client_dashboard.jsp"><button type="button">Cancel</button></a>
        </form>
    </div>
</body>
</html>
