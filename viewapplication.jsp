<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="javax.xml.transform.*, javax.xml.transform.stream.*, java.io.*" %>

<%
Integer userId = (Integer) session.getAttribute("user_id");
String role = (String) session.getAttribute("role");

if(userId == null){
    response.sendRedirect("login.jsp");
    return;
}

String xmlFile = application.getRealPath("/xml/applications.xml");
String xslFile = application.getRealPath("/WEB-INF/applications.xsl");

try {
    TransformerFactory factory = TransformerFactory.newInstance();
    Source xsl = new StreamSource(new File(xslFile));
    Transformer transformer = factory.newTransformer(xsl);

    transformer.setParameter("userId", userId);
    transformer.setParameter("role", role);

    Source xml = new StreamSource(new File(xmlFile));
    transformer.transform(xml, new StreamResult(out));

} catch(Exception e){
    out.println("<h3>Error: " + e.getMessage() + "</h3>");
}
%>