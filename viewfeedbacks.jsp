<%@ page import="javax.xml.transform.*, javax.xml.transform.stream.*, java.io.*" %>

<%
String filePath = application.getRealPath("/WEB-INF/feedbacks.xml");
    String xslFile = application.getRealPath("/feedback_style.xsl");

    TransformerFactory factory = TransformerFactory.newInstance();
    Transformer transformer = factory.newTransformer(new StreamSource(new File(xslFile)));

    response.setContentType("text/html");

    transformer.transform(
        new StreamSource(new File(filePath)),
        new StreamResult(out)
    );
%>