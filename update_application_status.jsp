<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>

<%
Integer companyId = (Integer) session.getAttribute("user_id");

if(companyId == null){
    response.sendRedirect("login.jsp");
    return;
}

// Get form data
String id = request.getParameter("id");
String status = request.getParameter("status");

if(id == null || status == null){
    out.println("Invalid request");
    return;
}

Connection conn = null;
PreparedStatement ps = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/oipwt", "root", "2005");

    // ✅ Update application status
    String sql = "UPDATE applications SET status=? WHERE id=?";
    ps = conn.prepareStatement(sql);
    ps.setString(1, status);
    ps.setInt(2, Integer.parseInt(id));

    int updated = ps.executeUpdate();

    if(updated > 0){
        // ✅ Redirect to regenerate XML again
        response.sendRedirect("generate_applications_xml.jsp");
    } else {
        out.println("Failed to update application");
    }

} catch(Exception e){
    e.printStackTrace();
    out.println("Error: " + e.getMessage());
} finally {
    if(ps != null) ps.close();
    if(conn != null) conn.close();
}
%>