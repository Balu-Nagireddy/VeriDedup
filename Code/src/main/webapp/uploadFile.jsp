<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.io.*, java.sql.*, javax.servlet.http.*, javax.servlet.annotation.*, javax.crypto.SecretKey, javax.crypto.spec.SecretKeySpec, java.util.Base64, java.security.MessageDigest, java.security.NoSuchAlgorithmException, com.veridedup.AESEncryptionUtil" %>
<%@ page import="javax.servlet.ServletException, javax.servlet.annotation.MultipartConfig, javax.servlet.http.Part" %>

<!DOCTYPE html>
<html>
<head>
    <title>Processing Upload...</title>
</head>
<body>
    <%
        if (!request.getContentType().startsWith("multipart/form-data")) {
            out.println("<p>Error: Form encoding must be multipart/form-data.</p>");
            return;
        }

        Part filePart = request.getPart("file");
        String fileName = request.getParameter("fileName");

        if (filePart != null && fileName != null) {
            InputStream fileContent = filePart.getInputStream();
            byte[] fileBytes = fileContent.readAllBytes();
            long fileSize = fileBytes.length;

            // Compute SHA-256 hash for file content
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] fileHashBytes = digest.digest(fileBytes);
            StringBuilder sb = new StringBuilder();
            for (byte b : fileHashBytes) {
                sb.append(String.format("%02x", b));
            }
            String fileHash = sb.toString();

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/VeriDedup", "root", "Rgukt143");

                // Check if the file name or file hash already exists
                String checkQuery = "SELECT * FROM files WHERE file_name = ? OR file_hash = ?";
                PreparedStatement checkPs = connection.prepareStatement(checkQuery);
                checkPs.setString(1, fileName);
                checkPs.setString(2, fileHash);
                ResultSet rs = checkPs.executeQuery();

                if (rs.next()) {
                    out.println("<p>Error: Duplicate file detected! File with the same content or name already exists.</p>");
                } else {
                    // Generate AES Key
                    SecretKey secretKey = AESEncryptionUtil.generateKey(128);
                    String encodedKey = AESEncryptionUtil.encodeKey(secretKey);

                    // Encrypt File Data
                    String encryptedData = AESEncryptionUtil.encrypt(new String(fileBytes, "UTF-8"), secretKey);

                    // Store in Database
                    String insertQuery = "INSERT INTO files (file_name, file_data, encryption_key, file_size, file_hash) VALUES (?, ?, ?, ?, ?)";
                    PreparedStatement ps = connection.prepareStatement(insertQuery);
                    ps.setString(1, fileName);
                    ps.setString(2, encryptedData);
                    ps.setString(3, encodedKey);
                    ps.setLong(4, fileSize);
                    ps.setString(5, fileHash);
                    ps.executeUpdate();

                    out.println("<p>File uploaded & encrypted successfully!</p>");
                    out.println("<p>File Size: " + fileSize + " bytes</p>");
                }
                
                checkPs.close();
                //ps.close();
                connection.close();

            } catch (Exception e) {
                e.printStackTrace();
                out.println("<p>Error uploading file: " + e.getMessage() + "</p>");
            }
        } else {
            out.println("<p>Invalid file upload.</p>");
        }
    %>
    <a href="upload.jsp">Back to Upload</a>
    <footer>
        <p>© 2025 VeriDedup | Secure Data Deduplication</p>
    </footer>
</body>
</html>