<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.io.*" %>

<%
Integer companyId = (Integer) session.getAttribute("user_id");

if(companyId == null){
    response.sendRedirect("login.jsp");
    return;
}

Connection conn = null;
PreparedStatement ps = null;
ResultSet rs = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/oipwt", "root", "2005");

    String sql = "SELECT a.id, a.company_name, a.internship_title, " +
                 "a.full_name, a.email, a.phone, a.education, a.branch, a.semester, " +
                 "a.skills, a.experience, a.applied_date, a.status, a.resume_path " +
                 "FROM applications a " +
                 "JOIN internships i ON a.internship_id = i.id " +
                 "WHERE i.company_id = ? " +
                 "ORDER BY a.applied_date DESC";

    ps = conn.prepareStatement(sql);
    ps.setInt(1, companyId);
    rs = ps.executeQuery();

    String xmlDir = application.getRealPath("/xml");
    File folder = new File(xmlDir);
    if(!folder.exists()) folder.mkdirs();

    String xmlPath = xmlDir + File.separator + "applications.xml";
    PrintWriter xmlWriter = new PrintWriter(new FileWriter(xmlPath));

    xmlWriter.println("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
    xmlWriter.println("<applications>");

    while(rs.next()){
        xmlWriter.println("<application>");

        xmlWriter.println("<id>" + rs.getInt("id") + "</id>");
        xmlWriter.println("<internship_title>" + rs.getString("internship_title") + "</internship_title>");
        xmlWriter.println("<company_name>" + rs.getString("company_name") + "</company_name>");

        xmlWriter.println("<student>");
        xmlWriter.println("<full_name>" + rs.getString("full_name") + "</full_name>");
        xmlWriter.println("<email>" + rs.getString("email") + "</email>");
        xmlWriter.println("<phone>" + rs.getString("phone") + "</phone>");
        xmlWriter.println("<education>" + rs.getString("education") + "</education>");
        xmlWriter.println("<branch>" + rs.getString("branch") + "</branch>");
        xmlWriter.println("<semester>" + rs.getString("semester") + "</semester>");
        xmlWriter.println("<skills>" + rs.getString("skills") + "</skills>");
        xmlWriter.println("<experience>" + rs.getString("experience") + "</experience>");
        xmlWriter.println("</student>");

        xmlWriter.println("<applied_date>" + rs.getTimestamp("applied_date") + "</applied_date>");
        xmlWriter.println("<status>" + rs.getString("status") + "</status>");
        xmlWriter.println("<resume>" + rs.getString("resume_path") + "</resume>");

        xmlWriter.println("</application>");
    }

    xmlWriter.println("</applications>");
    xmlWriter.close();

    response.sendRedirect("viewapplication.jsp");

} catch(Exception e){
    e.printStackTrace();
}
%>