<%@ page contentType="application/json;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.intern.dbconnection" %>

<%
    boolean exists = false;
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        // ✅ Get user_id from session
        Integer userId = (Integer) session.getAttribute("user_id");

        if (userId != null) {
            conn = dbconnection.getConnection();

            // ✅ Check using user_id ONLY
            String sql = "SELECT 1 FROM student_profiles WHERE user_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);

            rs = pstmt.executeQuery();

            if (rs.next()) {
                exists = true;
            }
        }

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }

    // ✅ IMPORTANT: return ONLY JSON
    out.clear();
    out.print("{\"exists\": " + exists + "}");
%>