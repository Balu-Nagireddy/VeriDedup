<%@page import="java.sql.*"%>
<%! 
    public Connection getConnection() throws SQLException, ClassNotFoundException {
        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection("jdbc:mysql://localhost:3306/VeriDedup", "root", "Rgukt143");
    }
	public void logAdminAction(String action, String performedBy) throws SQLException, ClassNotFoundException {
	    try (Connection conn = getConnection();
	         PreparedStatement ps = conn.prepareStatement("INSERT INTO audit_logs (action, performed_by) VALUES (?, ?)")) {
	        ps.setString(1, action);
	        ps.setString(2, performedBy);
	        ps.executeUpdate();
	    }
	}

    public int getTotalUsers() throws SQLException, ClassNotFoundException {
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM users");
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    public int getPendingUsers() throws SQLException, ClassNotFoundException {
        return getCount("SELECT COUNT(*) FROM users WHERE status = 'pending'");
    }

    public int getApprovedUsers() throws SQLException, ClassNotFoundException {
        return getCount("SELECT COUNT(*) FROM users WHERE status = 'approved'");
    }

    public int getTotalFiles() throws SQLException, ClassNotFoundException {
        return getCount("SELECT COUNT(*) FROM files");
    }

    public int getStorageUsage() throws SQLException, ClassNotFoundException {
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT SUM(LENGTH(file_data)) FROM files");
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) / 1024 / 1024 : 0; // Convert Bytes → MB
        }
    }


    private int getCount(String query) throws SQLException, ClassNotFoundException {
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }
%>
