package com.veridedup;

import java.io.IOException;
import java.io.OutputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Base64;
import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/DecryptFileServlet")
public class DecryptFileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String fileId = request.getParameter("fileId");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/VeriDedup", "root", "Rgukt143");

            // ✅ Fetch Encrypted File & Key
            String query = "SELECT file_name, file_data, encryption_key FROM files WHERE id = ?";
            PreparedStatement ps = connection.prepareStatement(query);
            ps.setString(1, fileId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String fileName = rs.getString("file_name");
                byte[] encryptedData = rs.getBytes("file_data");
                String encodedKey = rs.getString("encryption_key");

                // ✅ Decode Key & Perform AES Decryption
                byte[] decodedKey = Base64.getDecoder().decode(encodedKey);
                SecretKey secretKey = new SecretKeySpec(decodedKey, "AES");
                byte[] decryptedData = decryptAES(encryptedData, secretKey);

                // ✅ Serve File as Download
                response.setContentType("application/octet-stream");
                response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
                
                try (OutputStream outputStream = response.getOutputStream()) {
                    outputStream.write(decryptedData);
                    outputStream.flush();
                }
            } else {
                response.getWriter().println("Error: File not found.");
            }

            rs.close();
            ps.close();
            connection.close();
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error decrypting file: " + e.getMessage());
        }
    }

    private byte[] decryptAES(byte[] encryptedData, SecretKey secretKey) throws Exception {
        Cipher cipher = Cipher.getInstance("AES");
        cipher.init(Cipher.DECRYPT_MODE, secretKey);
        return cipher.doFinal(encryptedData);
    }
}
