<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/">

<html>
<head>
<title>Applications Table</title>
<link rel="stylesheet" href="css/all.min.css"></link>
<style>
body {
    font-family: Arial, sans-serif;
    background-image: url('images/44.jpg');
    margin: 0;
}

.header {
    background: linear-gradient(90deg, #0b3c5d, #3498db);
    color: white;
    padding: 20px;
    text-align: center;
    font-size: 22px;
    font-weight: bold;
    position: relative;
}

.back-btn {
    position: absolute;
    left: 20px;
    top: 12px;
    padding: 10px 18px;
    background: #e6e6e6;
    color: #333;
    text-decoration: none;
    font-size: 16px;
    font-weight: 500;
    border-radius: 25px;
    display: inline-flex;
    align-items: center;
    gap: 8px;
    transition: all 0.3s ease;
}

.back-btn:hover {
    background: #3498db;
    color: white;
}

table {
    width: 95%;
    margin: 30px auto;
    border-collapse: collapse;
    background: white;
    box-shadow: 0 5px 15px rgba(0,0,0,0.1);
}

th {
    background: linear-gradient(#0b3c5d, #3498db);
    color: white;
    padding: 12px;
    text-align: center;
}

td {
    padding: 10px;
    border-bottom: 1px solid #ddd;
    text-align: center;
}

tr:nth-child(even) {
    background: #f9f9f9;
}

tr:hover {
    background: #eef4ff;
}

.pending {
    color: orange;
    font-weight: bold;
}
.accepted {
    color: green;
    font-weight: bold;
}
.rejected {
    color: red;
    font-weight: bold;
}

.btn {
    padding: 6px 12px;
    border: none;
    border-radius: 5px;
    cursor: pointer;
}

.approve {
    background: green;
    color: white;
}

.reject {
    background: red;
    color: white;
}
</style>

</head>

<body>

<div class="header">
    <a href="companyhome.jsp" class="back-btn">
    <i class="fas fa-arrow-left"></i> Back to Dashboard
</a>
     <i class="fas fa-briefcase"></i> Applications
</div>

<table>

<tr>
    
    <th>Internship</th>
    <th>Company</th>
    <th>Name</th>
    <th>Email</th>
    <th>Phone</th>
    <th>Education</th>
    <th>Branch</th>
    <th>Skills</th>
    <th>Applied Date</th>
    <th>Status</th>
    <th>Resume</th>  
    <th>Action</th>
</tr>

<xsl:for-each select="applications/application">

<tr>
    <td><xsl:value-of select="internship_title"/></td>
    <td><xsl:value-of select="company_name"/></td>
    <td><xsl:value-of select="student/full_name"/></td>
    <td><xsl:value-of select="student/email"/></td>
    <td><xsl:value-of select="student/phone"/></td>
    <td><xsl:value-of select="student/education"/></td>
    <td><xsl:value-of select="student/branch"/></td>
    <td><xsl:value-of select="student/skills"/></td>
    <td><xsl:value-of select="applied_date"/></td>

    <td>
        <span>
            <xsl:attribute name="class">
                <xsl:choose>
                    <xsl:when test="status='Accepted'">accepted</xsl:when>
                    <xsl:when test="status='Rejected'">rejected</xsl:when>
                    <xsl:otherwise>pending</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:value-of select="status"/>
        </span>
    </td>

    <td>
        <a target="_blank">
            <xsl:attribute name="href">
                <xsl:value-of select="concat('/oipwtt/', resume)"/>
            </xsl:attribute>

            <i class="fas fa-file-pdf" style="color:red;"></i> View
        </a>
    </td>

    <td>
        <xsl:if test="status='Pending' or status='pending'">
            <form action="update_application_status.jsp" method="post" style="display:inline;">
                <input type="hidden" name="id" value="{id}"/>
                <button type="submit" name="status" value="Accepted" class="btn approve">Approve</button>
                <button type="submit" name="status" value="Rejected" class="btn reject">Reject</button>
            </form>
        </xsl:if>

        <xsl:if test="status='Accepted' or status='Rejected'">
            Done
        </xsl:if>
    </td>
</tr>

</xsl:for-each>

</table>

</body>
</html>

</xsl:template>
</xsl:stylesheet>