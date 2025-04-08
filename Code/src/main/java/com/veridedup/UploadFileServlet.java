package com.veridedup;

import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Arrays;
import javax.crypto.SecretKey;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

@WebServlet("/UploadFileServlet")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024, // 1MB
        maxFileSize = 100 * 1024 * 1024,  // 100MB
        maxRequestSize = 200 * 1024 * 1024 // 200MB
)
public class UploadFileServlet extends HttpServlet {

    private static final long serialVersionUID = 3772432175685924915L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            Part filePart = request.getPart("file");
            String fileName = request.getParameter("fileName");
            String verificationTag = request.getParameter("verificationTag");
            int userId = Integer.parseInt(request.getParameter("user_id")); 
            boolean forceUpload = "true".equals(request.getParameter("forceUpload"));

            if (filePart == null || fileName == null || fileName.isEmpty() || verificationTag == null || verificationTag.isEmpty()) {
                response.sendRedirect("client_dashboard.jsp?message=Error: Missing file, filename, or verification tag");
                return;
            }

            InputStream fileContent = filePart.getInputStream();
            byte[] fileBytes = fileContent.readAllBytes();
            long fileSizeBytes = fileBytes.length;

            // Compute SHA-256 hash for file content
            String fileHash = computeSHA256(fileBytes);
            String challenge = generateChallenge(fileHash);

            // Generate verification notes
            byte[] verificationNotes = generateVerificationNotes(fileBytes);

            // Check if file name exists
            if (!forceUpload && isDuplicateFileName(fileName)) {
                sendDuplicateFileNameAlert(response, fileName);
                return;
            }

            // Encrypt file
            SecretKey secretKey = AESEncryptionUtil.generateKey(128);
            String encodedKey = AESEncryptionUtil.encodeKey(secretKey);
            byte[] encryptedData = AESEncryptionUtil.encryptBytes(fileBytes, secretKey);

            // Check for duplicate content using block-by-block validation
            if (!forceUpload && isDuplicateFileByContent(fileBytes, challenge)) {
                sendDuplicateFileContentAlert(response);
                return;
            }

            // Store file in database
            int fileId = storeFileInDatabase(fileName, encryptedData, encodedKey, userId, fileSizeBytes, fileHash);
            storeVerificationTag(fileId, verificationTag);
            updateFilter(fileHash);
            storeVerificationNotes(fileId, verificationNotes);

            response.sendRedirect("client_dashboard.jsp?message=File uploaded successfully!");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("client_dashboard.jsp?message=Error uploading file: " + e.getMessage());
        }
    }

    private byte[] generateVerificationNotes(byte[] fileData) {
        byte[] notes = new byte[64];
        new SecureRandom().nextBytes(notes);
        return notes;
    }

    private String computeSHA256(byte[] data) throws NoSuchAlgorithmException {
        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        byte[] hash = digest.digest(data);
        StringBuilder hexString = new StringBuilder();
        for (byte b : hash) {
            hexString.append(String.format("%02x", b));
        }
        return hexString.toString();
    }

    private boolean isDuplicateFileName(String fileName) throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/VeriDedup", "root", "Rgukt143");
             PreparedStatement ps = connection.prepareStatement("SELECT file_name FROM files WHERE file_name = ?")) {
            ps.setString(1, fileName);
            ResultSet rs = ps.executeQuery();
            return rs.next();
        }
    }

    private void sendDuplicateFileContentAlert(HttpServletResponse response) throws IOException {
        PrintWriter out = response.getWriter();
        out.println("<script>");
        out.println("if (confirm('⚠️ Warning: A file with identical content already exists. Do you want to continue?')) {");
        out.println("    window.location.href = 'upload.jsp?forceUpload=true';"); 
        out.println("} else {");
        out.println("    window.location.href = 'client_dashboard.jsp?message=Upload Cancelled';");
        out.println("}");
        out.println("</script>");
        out.close();
    }
    private void sendDuplicateFileNameAlert(HttpServletResponse response, String fileName) throws IOException {
        PrintWriter out = response.getWriter();
        out.println("<script>");
        out.println("if (confirm('⚠️ Warning: A file with the name \"" + fileName + "\" already exists. Do you want to continue?')) {");
        out.println("    window.location.href = 'upload.jsp?forceUpload=true';"); 
        out.println("} else {");
        out.println("    window.location.href = 'client_dashboard.jsp?message=Upload Cancelled';");
        out.println("}");
        out.println("</script>");
        out.close();
    }

    private int storeFileInDatabase(String fileName, byte[] encryptedData, String encodedKey, int userId, long fileSize, String fileHash) throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
        int fileId = -1;

        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/VeriDedup", "root", "Rgukt143");
             PreparedStatement ps = connection.prepareStatement(
                     "INSERT INTO files (file_name, file_data, encryption_key, user_id, file_size, file_hash) VALUES (?, ?, ?, ?, ?, ?)", 
                     PreparedStatement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, fileName);
            ps.setBytes(2, encryptedData);
            ps.setString(3, encodedKey);
            ps.setInt(4, userId);
            ps.setLong(5, fileSize);
            ps.setString(6, fileHash);
            ps.executeUpdate();

            ResultSet rs = ps.getGeneratedKeys();
            if (rs.next()) {
                fileId = rs.getInt(1);
            }
        }
        return fileId;
    }

    private boolean isDuplicateFileByContent(byte[] fileBytes, String challenge) throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/VeriDedup", "root", "Rgukt143");
             PreparedStatement ps = connection.prepareStatement("SELECT file_data, encryption_key FROM files")) {

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                byte[] encryptedData = rs.getBytes("file_data");
                String encodedKey = rs.getString("encryption_key");
                SecretKey secretKey = AESEncryptionUtil.decodeKey(encodedKey);
                byte[] decryptedData = AESEncryptionUtil.decryptBytes(encryptedData, secretKey);

                if (Arrays.equals(fileBytes, decryptedData)) {
                    return true;
                }
            }
        }
        return false;
    }

    private String generateChallenge(String fileHash) throws NoSuchAlgorithmException {
        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        return bytesToHex(digest.digest((fileHash + "randomFactor").getBytes()));
    }

    private void storeVerificationNotes(int fileId, byte[] notes) throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/VeriDedup", "root", "Rgukt143");
             PreparedStatement ps = connection.prepareStatement("INSERT INTO verification_notes (file_id, verification_notes) VALUES (?, ?)")) {
            ps.setInt(1, fileId);
            ps.setBytes(2, notes);
            ps.executeUpdate();
        }
    }

    private static String bytesToHex(byte[] bytes) {
        StringBuilder hexString = new StringBuilder();
        for (byte b : bytes) {
            hexString.append(String.format("%02x", b));
        }
        return hexString.toString();
    }
    private void storeVerificationTag(int fileId, String verificationTag) throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/VeriDedup", "root", "Rgukt143");
             PreparedStatement ps = connection.prepareStatement("INSERT INTO verification_tags (file_id, verification_tag) VALUES (?, ?)")) {
            ps.setInt(1, fileId);
            ps.setString(2, verificationTag);
            ps.executeUpdate();
        }
    }

    private void updateFilter(String fileHash) {
        if (!CuckooFilter.containsTag(fileHash)) {
            CuckooFilter.insertTag(fileHash);
        }
    }
}
