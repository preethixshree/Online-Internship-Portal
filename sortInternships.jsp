<%@ page import="java.sql.*" %>
<%@ page import="com.intern.dbconnection" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
String sortBy = request.getParameter("sortBy");

String orderBy = "i.posted_date DESC";

if("oldest".equals(sortBy))
    orderBy = "i.posted_date ASC";
else if("az".equals(sortBy))
    orderBy = "i.title ASC";
else if("za".equals(sortBy))
    orderBy = "i.title DESC";

Connection conn = null;
Statement stmt = null;
ResultSet rs = null;

try {
    conn = dbconnection.getConnection();
    stmt = conn.createStatement();
    
    String sql = "SELECT i.*, u.username as company_name FROM internships i " +
                 "LEFT JOIN users u ON i.company_id = u.id " +
                 "WHERE i.status = 'Active' " +
                 "ORDER BY " + orderBy;
    
    rs = stmt.executeQuery(sql);
    
    boolean hasResults = false;
    
    while(rs.next()){
        hasResults = true;
        
        String title = rs.getString("title");
        String company = rs.getString("company_name");
        if(company == null) company = "Company";
        String location = rs.getString("location");
        if(location == null) location = "Location not specified";
        String type = rs.getString("type");
        String duration = rs.getString("duration");
        int openings = rs.getInt("openings");
        String stipendType = rs.getString("stipend_type");
        String amount = rs.getString("amount");
        String description = rs.getString("description");
        if(description != null && description.length() > 120){
            description = description.substring(0,120) + "...";
        }
        
        // Format deadline
        String deadlineFormatted = "No deadline";
        Date deadline = rs.getDate("deadline");
        if(deadline != null){
            SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy");
            deadlineFormatted = sdf.format(deadline);
        }
        
        // Format stipend display
        String stipendDisplay = stipendType;
        if("Paid".equals(stipendType) && amount != null && !amount.isEmpty()){
            stipendDisplay = "₹" + amount + "/month";
        }
%>

<div class="live-internship-card" 
     data-id="<%= rs.getInt("id") %>"
     data-title="<%= title %>"
     data-company="<%= company %>"
     data-location="<%= location %>"
     data-description="<%= rs.getString("description") != null ? rs.getString("description") : "" %>">
     
    <div class="live-card-header">
        <h3><%= title %></h3>
        <span class="company-badge">
            <i class="fas fa-building"></i> <%= company %>
        </span>
    </div>
    
    <div class="live-card-body">
        <p class="location">
            <i class="fas fa-map-marker-alt"></i> 
            <%= location %>
        </p>
        
        <p>
            <i class="fas fa-clock"></i> 
            <%= type %> • <%= duration %>
        </p>
        
        <p>
            <i class="fas fa-users"></i> 
            <%= openings %> <%= openings > 1 ? "Openings" : "Opening" %>
        </p>
        
        <p class="stipend-info">
            <i class="fas fa-money-bill-wave"></i> 
            <%= stipendDisplay %>
        </p>
        
        <% if(description != null && !description.isEmpty()) { %>
            <div class="description-preview">
                <i class="fas fa-quote-left" style="font-size: 10px; opacity: 0.5;"></i>
                <%= description %>
            </div>
        <% } %>
    </div>
    
    <div class="live-card-footer">
        <span class="deadline-badge">
            <i class="fas fa-calendar-alt"></i> 
            Deadline: <%= deadlineFormatted %>
        </span>
        
        <a href="intdesc.jsp?id=<%= rs.getInt("id") %>" class="view-details-btn">
            View Details <i class="fas fa-arrow-right"></i>
        </a>
    </div>
</div>

<%
    }
    
    if(!hasResults){
%>
    <div class="no-internships-message" style="grid-column: 1 / -1; text-align: center; padding: 60px;">
        <i class="fas fa-briefcase" style="font-size: 48px; margin-bottom: 20px; opacity: 0.5;"></i>
        <h3>No internships found</h3>
        <p>Check back later for new opportunities!</p>
    </div>
<%
    }
    
} catch(Exception e){
    e.printStackTrace();
%>
    <div class="error-message" style="grid-column: 1 / -1; background: #f8d7da; color: #721c24; text-align: center; padding: 40px; border-radius: 8px; margin: 20px;">
        <i class="fas fa-exclamation-circle" style="font-size: 36px; margin-bottom: 15px;"></i>
        <h3>Error loading internships</h3>
        <p><%= e.getMessage() %></p>
    </div>
<%
} finally {
    if(rs != null) try { rs.close(); } catch(Exception e) {}
    if(stmt != null) try { stmt.close(); } catch(Exception e) {}
    if(conn != null) try { conn.close(); } catch(Exception e) {}
}
%>