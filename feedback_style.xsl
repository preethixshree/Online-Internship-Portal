<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/">

<html>

<head>

<title>Internship Feedbacks</title>

<style>

body{
    font-family: Arial, sans-serif;
    background-image: url('images/44.jpg');
    margin:0;
}

.header{
    background: linear-gradient(90deg,#0b3c5d,#3498db);
    color:white;
    padding:20px;
    text-align:center;
    font-size:22px;
    font-weight:bold;
    position:relative;
}
.back-btn{
    position:absolute;
    left:20px;
    top:12px;
    padding:10px 18px;
    background:#e6e6e6;
    color:#333;
    text-decoration:none;
    font-size:16px;
    font-weight:500;
    border-radius:25px;
    display:inline-flex;
    align-items:center;
    gap:8px;
    transition:all 0.3s ease;
}

.back-btn:hover{
    background:#3498db;
    color:white;
}

.back-btn:active{
    background:#1e6fa8;
    color:white;
}
.container{
    width:90%;
    max-width:1000px;
    margin:40px auto;
    background:white;
    border-radius:10px;
    box-shadow:0 4px 10px rgba(0,0,0,0.1);
    padding:25px;
}

table{
    width:100%;
    border-collapse:collapse;
    margin-top:20px;
}

th{
    background:linear-gradient(#0b3c5d,#3498db);
    color:white;
    padding:12px;
    text-align:left;
}

td{
    padding:10px;
    border-bottom:1px solid #ddd;
}

tr:nth-child(even){
    background:#f9f9f9;
}

tr:hover{
    background:#eef4ff;
}

.title{
    font-size:20px;
    font-weight:bold;
    margin-bottom:10px;
}

</style>

</head>

<body>

<div class="header">
<a href="studenthome.jsp" class="back-btn">&#8592; Back to Dashboard</a>
Online Internship Portal - Feedback
</div>

<div class="container">

<div class="title">Student Internship Feedbacks</div>

<table>

<tr>
<th>Name</th>
<th>Email</th>
<th>Internship Type</th>
<th>Rating</th>
<th>Comments</th>
</tr>

<xsl:for-each select="feedbacks/feedback">

<tr>

<td>
<xsl:value-of select="name"/>
</td>

<td>
<xsl:value-of select="email"/>
</td>

<td>
<xsl:value-of select="internshipType"/>
</td>

<td>
<xsl:if test="rating != ''">
⭐ <xsl:value-of select="rating"/> / 5
</xsl:if>
</td>

<td>
<xsl:value-of select="comments"/>
</td>

</tr>

</xsl:for-each>

</table>

</div>

</body>

</html>

</xsl:template>

</xsl:stylesheet>