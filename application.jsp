<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, javax.xml.parsers.*, org.w3c.dom.*, javax.xml.transform.*, javax.xml.transform.dom.*, javax.xml.transform.stream.*" %>
<%@ page import="com.intern.dbconnection" %>

<%
    Integer userId = (Integer) session.getAttribute("user_id");

    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    StringWriter xmlWriter = new StringWriter();

    try {
        con = dbconnection.getConnection();

        String query = "SELECT * FROM applications WHERE user_id = ?";
        ps = con.prepareStatement(query);
        ps.setInt(1, userId);
        rs = ps.executeQuery();

        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        DocumentBuilder builder = factory.newDocumentBuilder();
        Document doc = builder.newDocument();

        Element root = doc.createElement("applications");
        doc.appendChild(root);

        while (rs.next()) {
            Element app = doc.createElement("application");

            Element company = doc.createElement("company_name");
            company.appendChild(doc.createTextNode(rs.getString("company_name")));
            app.appendChild(company);

            Element title = doc.createElement("internship_title");
            title.appendChild(doc.createTextNode(rs.getString("internship_title")));
            app.appendChild(title);

            Element name = doc.createElement("full_name");
            name.appendChild(doc.createTextNode(rs.getString("full_name")));
            app.appendChild(name);

            Element email = doc.createElement("email");
            email.appendChild(doc.createTextNode(rs.getString("email")));
            app.appendChild(email);

            Element phone = doc.createElement("phone");
            phone.appendChild(doc.createTextNode(rs.getString("phone")));
            app.appendChild(phone);

            Element status = doc.createElement("status");
            status.appendChild(doc.createTextNode(rs.getString("status")));
            app.appendChild(status);

            Element date = doc.createElement("applied_date");
            date.appendChild(doc.createTextNode(rs.getString("applied_date")));
            app.appendChild(date);

            root.appendChild(app);
        }

        TransformerFactory tf = TransformerFactory.newInstance();
        Transformer transformer = tf.newTransformer();
        transformer.transform(new DOMSource(doc), new StreamResult(xmlWriter));

        String xmlData = xmlWriter.toString();

%>

<!DOCTYPE html>
<html>
<head>
    <title>My Applications</title>
    <style>
        body { font-family: Arial; }
        table {
            border-collapse: collapse;
            width: 100%;
            margin-top: 20px;
        }
        th, td {
            border: 1px solid #ccc;
            padding: 10px;
            text-align: center;
        }
        th {
            background-color: #2c3e50;
            color: white;
        }
    </style>
</head>
<body>

<h2>My Applications (XML Table View)</h2>

<%
        Document parsedDoc = builder.parse(new java.io.ByteArrayInputStream(xmlData.getBytes()));
        NodeList list = parsedDoc.getElementsByTagName("application");
%>

<table>
    <tr>
        <th>Company</th>
        <th>Internship</th>
        <th>Name</th>
        <th>Email</th>
        <th>Phone</th>
        <th>Status</th>
        <th>Applied Date</th>
    </tr>

<%
    for (int i = 0; i < list.getLength(); i++) {
        Element e = (Element) list.item(i);
%>

<tr>
    <td><%= e.getElementsByTagName("company_name").item(0).getTextContent() %></td>
    <td><%= e.getElementsByTagName("internship_title").item(0).getTextContent() %></td>
    <td><%= e.getElementsByTagName("full_name").item(0).getTextContent() %></td>
    <td><%= e.getElementsByTagName("email").item(0).getTextContent() %></td>
    <td><%= e.getElementsByTagName("phone").item(0).getTextContent() %></td>
    <td><%= e.getElementsByTagName("status").item(0).getTextContent() %></td>
    <td><%= e.getElementsByTagName("applied_date").item(0).getTextContent() %></td>
</tr>

<%
    }
%>

</table>

</body>
</html>

<%
    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
    } finally {
        if (rs != null) rs.close();
        if (ps != null) ps.close();
        if (con != null) con.close();
    }
%>