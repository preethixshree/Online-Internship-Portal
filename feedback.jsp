<%@ page import="java.io.*, javax.xml.parsers.*, org.w3c.dom.*, javax.xml.transform.*, javax.xml.transform.dom.*, javax.xml.transform.stream.*" %>

<%
String name = request.getParameter("name");

if(name != null){

String email = request.getParameter("email")==null?"":request.getParameter("email");
String type = request.getParameter("internshipType")==null?"":request.getParameter("internshipType");
String rating = request.getParameter("rating")==null?"":request.getParameter("rating");
String comments = request.getParameter("comments")==null?"":request.getParameter("comments");
String suggestions = request.getParameter("suggestions")==null?"":request.getParameter("suggestions");

String path = application.getRealPath("/WEB-INF/feedbacks.xml");
File file = new File(path);

DocumentBuilder builder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
Document doc;
Element root;

if(file.exists()){
    doc = builder.parse(file);
    root = doc.getDocumentElement();
}else{
    doc = builder.newDocument();
    root = doc.createElement("feedbacks");
    doc.appendChild(root);
}

Element feedback = doc.createElement("feedback");

String[][] data = {
{"name",name},
{"email",email},
{"internshipType",type},
{"rating",rating},
{"comments",comments},
{"suggestions",suggestions},
{"timestamp",new java.util.Date().toString()}
};

for(String[] d : data){
Element e = doc.createElement(d[0]);
e.appendChild(doc.createTextNode(d[1]));
feedback.appendChild(e);
}

root.appendChild(feedback);

Transformer t = TransformerFactory.newInstance().newTransformer();
t.setOutputProperty(OutputKeys.INDENT,"yes");
t.transform(new DOMSource(doc), new StreamResult(file));

response.sendRedirect("viewfeedbacks.jsp");
}
%>

<!DOCTYPE html>
<html>
<head>
<title>Internship Feedback</title>

<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="css/all.min.css">

<style>

*{box-sizing:border-box;}

body{
font-family:'Poppins',sans-serif;
background:url(images/44.jpg) center/cover no-repeat;
margin:0;
height:100vh;
display:flex;
align-items:center;
justify-content:center;
}

/* Back Button */
.back-btn{
position:fixed;
top:25px;
left:25px;
padding:10px 18px;
background:#e6e6e6;
color:#333;
text-decoration:none;
font-size:15px;
border-radius:25px;
display:flex;
align-items:center;
gap:6px;
font-weight:500;
transition:0.3s;
box-shadow:0 3px 8px rgba(0,0,0,0.15);
}

.back-btn:hover{
background:#3498db;
color:#fff;
}

/* Card */
.container{
width:650px;
background:#fff;
border-radius:12px;
box-shadow:0 10px 30px rgba(0,0,0,0.25);
overflow:hidden;
}

/* Header */
h2{
margin:0;
padding:20px;
background:linear-gradient(90deg,#0b3c5d,#3498db);
color:#fff;
text-align:center;
font-size:24px;
}

/* Form */
form{
padding:28px;
background:#f4f6f9;
}

/* Labels */
label{
display:flex;
align-items:center;
gap:8px;
margin-top:14px;
font-size:14px;
font-weight:500;
color:#2c3e50;
}

label i{
color:#3498db;
}

/* Inputs */
input,
select,
textarea{
width:100%;
padding:11px;
margin-top:6px;
border-radius:6px;
border:1px solid #dcdcdc;
font-size:14px;
background:#fff;
}

/* Focus */
input:focus,
select:focus,
textarea:focus{
outline:none;
border-color:#3498db;
box-shadow:0 0 5px rgba(52,152,219,0.4);
}

/* Textarea */
textarea{
min-height:90px;
resize:vertical;
}

/* Button */
button{
margin-top:22px;
width:100%;
padding:13px;
background:linear-gradient(90deg,#0b3c5d,#3498db);
color:#fff;
border:none;
border-radius:6px;
font-size:16px;
font-weight:600;
cursor:pointer;
transition:.3s;
}

button:hover{
background:linear-gradient(90deg,#092c44,#2176bd);
transform:translateY(-2px);
}
</style>
</head>

<body>

<a href="studenthome.jsp" class="back-btn">
<i class="fa fa-arrow-left"></i> Back to Dashboard
</a>

<div class="container">

<h2>Internship Feedback Form</h2>

<form method="post">

<label><i class="fa fa-user"></i> Name</label>
<input type="text" name="name" required>

<label><i class="fa fa-envelope"></i> Email</label>
<input type="email" name="email" required>

<label><i class="fa fa-laptop-code"></i> Internship Type</label>
<select name="internshipType">
<option>Web Development</option>
<option>Data Science</option>
<option>AI/ML</option>
<option>UI/UX</option>
</select>

<label><i class="fa fa-star"></i> Rating (1-5)</label>
<input type="number" name="rating" min="1" max="5">

<label><i class="fa fa-comment"></i> Comments</label>
<textarea name="comments"></textarea>

<label><i class="fa fa-lightbulb"></i> Suggestions</label>
<textarea name="suggestions"></textarea>

<button type="submit">Submit Feedback</button>

</form>

</div>

</body>
</html>