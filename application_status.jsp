<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.internship.dbconnection" %>

<%
    Integer userId = (Integer) session.getAttribute("user_id");
    String role = (String) session.getAttribute("role");

    if (userId == null || !"student".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<Map<String, String>> applications = new ArrayList<>();

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        conn = dbconnection.getConnection();

        String sql = "SELECT i.company_name, i.title, a.status, a.applied_date " +
                     "FROM applications a " +
                     "JOIN internships i ON a.internship_id = i.id " +
                     "WHERE a.student_id = ? ORDER BY a.applied_date DESC";

        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, userId);
        rs = pstmt.executeQuery();

        SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy");

        while (rs.next()) {
            Map<String, String> app = new HashMap<>();
            app.put("company", rs.getString("company_name"));
            app.put("title", rs.getString("title"));
            app.put("status", rs.getString("status"));

            Timestamp ts = rs.getTimestamp("applied_date");
            app.put("date", ts != null ? sdf.format(ts) : "N/A");

            applications.add(app);
        }

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        dbconnection.closeConnection(conn);
    }

    // Function to convert status → percentage
    int getProgress(String status) {
        if (status == null) return 0;
        switch(status) {
            case "pending": return 25;
            case "shortlisted": return 60;
            case "accepted": return 100;
            case "rejected": return 100;
            default: return 10;
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>My Applications</title>

    <!-- COMMON CSS -->
    <link rel="stylesheet" href="auth-styles.css">

    <style>
        .app-card {
            background: #fff;
            border-radius: 10px;
            padding: 20px;
            margin: 15px;
            box-shadow: var(--shadow);
        }

        .app-title {
            font-size: 18px;
            color: var(--dark-blue);
            font-weight: 600;
        }

        .app-sub {
            font-size: 13px;
            color: #666;
            margin-bottom: 10px;
        }

        .progress-bar {
            height: 8px;
            background: #eee;
            border-radius: 5px;
            overflow: hidden;
        }

        .progress-fill {
            height: 100%;
            background: var(--primary-blue);
            width: 0%;
            transition: 0.4s;
        }

        .status-text {
            margin-top: 5px;
            font-size: 12px;
            color: #555;
            text-transform: capitalize;
        }
    </style>
</head>

<body>

<div class="container">
    <div class="header">
        <h1>My Application Status</h1>
        <p>Track your internship applications</p>
    </div>

    <div class="form-section">

        <% if (applications.isEmpty()) { %>
            <p>No applications found.</p>
        <% } else { %>

            <% for (Map<String, String> app : applications) {
                int progress = getProgress(app.get("status"));
            %>

            <div class="app-card">
                <div class="app-title"><%= app.get("title") %></div>
                <div class="app-sub">
                    <%= app.get("company") %> • Applied on <%= app.get("date") %>
                </div>

                <div class="progress-bar">
                   <div class="progress-fill" style="width:<%= progress %>%"></div>
                </div>

                <div class="status-text">
                    Status: <%= app.get("status") %>
                </div>
            </div>

            <% } %>

        <% } %>

    </div>
</div>

</body>
</html>