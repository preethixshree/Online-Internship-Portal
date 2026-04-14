<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat" %>
<%@ page import="java.net.URLDecoder" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.intern.dbconnection" %>

<%
    java.util.Date now = new java.util.Date();
    SimpleDateFormat timeFormat = new SimpleDateFormat("hh:mm:ss a");
    String currentTime = timeFormat.format(now);
    
    SimpleDateFormat dateFormat = new SimpleDateFormat("EEEE, dd MMM yyyy");
    String currentDate = dateFormat.format(now);

    String welcomeMessage = "Welcome!";
    Cookie[] cookies = request.getCookies();
    if (cookies != null) {
        for (Cookie cookie : cookies) {
            if ("welcome_message".equals(cookie.getName())) {
                welcomeMessage = URLDecoder.decode(cookie.getValue(), "UTF-8");
            }
        }
    }

    boolean isLoggedIn = session.getAttribute("username") != null;
    String username = isLoggedIn ? (String) session.getAttribute("username") : "Guest";
    
    String lastLogin = (String) session.getAttribute("last_login_time");
    Integer userId = (Integer) session.getAttribute("user_id");
    String role = (String) session.getAttribute("role");
    
    String message = welcomeMessage; 

    int visitCount = 0;

    if (message != null) {
        java.util.regex.Pattern p = java.util.regex.Pattern.compile("#(\\d+)");
        java.util.regex.Matcher m = p.matcher(message);

        if (m.find()) {
            visitCount = Integer.parseInt(m.group(1));
        }
    }

    session.setAttribute("visit_count", visitCount);
    
    String formattedCurrentLogin = currentTime;
    String formattedLastLogin = (lastLogin != null && !lastLogin.trim().isEmpty()) ? lastLogin : "First time login";
    
    if (lastLogin != null && !lastLogin.equals("First time login")) {
        try {
            formattedLastLogin = lastLogin;
        } catch (Exception e) {
            formattedLastLogin = lastLogin;
        }
    }
    
    String hexSessionId = session.getId();
    String shortSessionId = hexSessionId != null && hexSessionId.length() > 8 ? 
        hexSessionId.substring(0, 8) + "..." : (hexSessionId != null ? hexSessionId : "N/A");
        
    String deleteId = request.getParameter("delete_id");
    String deleteMessage = null;
    
    
if (deleteId != null && !deleteId.trim().isEmpty()) {
    Connection deleteConn = null;
    PreparedStatement deletePstmt = null;
    ResultSet rsCheck = null;

    try {
        int internshipId = Integer.parseInt(deleteId);
        deleteConn = dbconnection.getConnection();

        String checkSql = "SELECT * FROM internships WHERE id = ? AND company_id = ?";
        deletePstmt = deleteConn.prepareStatement(checkSql);
        deletePstmt.setInt(1, internshipId);
        deletePstmt.setInt(2, userId);
        rsCheck = deletePstmt.executeQuery();

        if (rsCheck.next()) {
            rsCheck.close();
            deletePstmt.close();

            String deleteSql = "DELETE FROM internships WHERE id = ?";
            deletePstmt = deleteConn.prepareStatement(deleteSql);
            deletePstmt.setInt(1, internshipId);

            int rowsAffected = deletePstmt.executeUpdate();

            if (rowsAffected > 0) {
                deleteMessage = "Internship deleted successfully!";
            } else {
                deleteMessage = "Failed to delete internship.";
            }

        } else {
            // ❗ Only shows if NOT owned by this company OR doesn't exist
            deleteMessage = "Internship not found.";
        }

    } catch (Exception e) {
        deleteMessage = "Error: " + e.getMessage();
        e.printStackTrace();
    } finally {
        dbconnection.closeConnection(deleteConn);
        if (deletePstmt != null) try { deletePstmt.close(); } catch (SQLException e) {}
        if (rsCheck != null) try { rsCheck.close(); } catch (SQLException e) {}
    }
}

%>

<%
    List<Map<String, Object>> companyInternships = new ArrayList<>();
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        conn = dbconnection.getConnection();
        
        String sql = "SELECT * FROM internships WHERE company_id = ? ORDER BY posted_date DESC";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, userId);
        rs = pstmt.executeQuery();
        
        while (rs.next()) {
            Map<String, Object> internship = new HashMap<>();

            internship.put("id", rs.getInt("id"));
            internship.put("title", rs.getString("title"));
            internship.put("location", rs.getString("location"));
            internship.put("type", rs.getString("type"));
            internship.put("duration", rs.getString("duration"));
            internship.put("stipend_type", rs.getString("stipend_type"));
            internship.put("amount", rs.getBigDecimal("amount"));
            internship.put("description", rs.getString("description"));
            internship.put("openings", rs.getInt("openings"));
            internship.put("deadline", rs.getDate("deadline"));
            internship.put("status", rs.getString("status"));
            internship.put("posted_date", rs.getTimestamp("posted_date"));

            companyInternships.add(internship);
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        dbconnection.closeConnection(conn);
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
    }
    
    // Get counts for statistics
    int totalInternships = companyInternships.size();
    java.util.Date currentDateObj = new java.util.Date();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Company Dashboard - Online Internship Portal</title>
    <link rel="stylesheet" href="stylehome.css">
    <link rel="stylesheet" href="css/all.min.css">
    <script src="stylescript.js"></script>
    <style>
        .quick-actions {
            display: flex;
            gap: 20px;
            margin: 30px 0;
            flex-wrap: wrap;
        }
        
        .action-btn {
            flex: 1;
            background: white;
            border: 2px solid var(--primary-blue);
            padding: 15px;
            border-radius: 10px;
            text-align: center;
            transition: all 0.3s;
            text-decoration: none;
            color: var(--primary-blue);
        }
        
        .action-btn:hover {
            background: var(--primary-blue);
            color: white;
            transform: translateY(-3px);
        }
        
        .action-btn i {
            font-size: 24px;
            display: block;
            margin-bottom: 10px;
        }
        
        .internship-status {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
        }
        
        .status-active {
            background: #d4edda;
            color: #155724;
        }
        
        .status-expired {
            background: #f8d7da;
            color: #721c24;
        }
        
        .status-draft {
            background: #fff3cd;
            color: #856404;
        }
        
        .company-internship-card {
            background: white;
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            transition: transform 0.3s, box-shadow 0.3s;
        }
        
        .company-internship-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 5px 20px rgba(0,0,0,0.1);
        }
        
        .card-header-company {
            display: flex;
            justify-content: space-between;
            align-items: start;
            margin-bottom: 15px;
            flex-wrap: wrap;
        }
        
        .card-header-company h3 {
            margin: 0;
            color: var(--primary-blue);
            font-size: 20px;
        }
        
        .card-actions {
            display: flex;
            gap: 10px;
        }
        
        .delete-btn {
            padding: 6px 12px;
            border-radius: 6px;
            text-decoration: none;
            font-size: 13px;
            transition: all 0.3s;
            background: #dc3545;
            color: white;
            border: none;
            cursor: pointer;
        }
        
        .delete-btn:hover {
            background: #c82333;
        }
        
        .view-applications-btn {
            padding: 6px 12px;
            border-radius: 6px;
            text-decoration: none;
            font-size: 13px;
            transition: all 0.3s;
            background: var(--primary-blue);
            color: white;
        }
        
        .view-applications-btn:hover {
            background: #1a4d8a;
        }
        
        .no-internships {
            text-align: center;
            padding: 60px 20px;
            background: white;
            border-radius: 12px;
        }
        
        .no-internships i {
            font-size: 64px;
            color: #ccc;
            margin-bottom: 20px;
        }
        
        .post-first-btn {
            display: inline-block;
            margin-top: 20px;
            padding: 12px 30px;
            background: var(--primary-blue);
            color: white;
            text-decoration: none;
            border-radius: 8px;
            transition: all 0.3s;
        }
        
        .post-first-btn:hover {
            background: #1a4d8a;
            transform: translateY(-2px);
        }
        
        .delete-message {
            padding: 10px 20px;
            margin: 10px 0;
            border-radius: 8px;
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        
        .delete-message.error {
            background: #f8d7da;
            color: #721c24;
            border-color: #f5c6cb;
        }
    </style>
</head>
<body>
    <div id="sidebar" class="sidebar">
        <h3>👤 Company Session Info</h3>
        <div id="sessionContainer"></div>
    </div>

    <div class="headingbox">
        <div class="header-content">
            <div class="menu-icon" onclick="toggleSidebar()">
                <i class="fas fa-bars"></i>
            </div>
            
            <div class="headingtext">
                <i class="fas fa-building"></i>
                Company Dashboard - Online Internship Portal
            </div>
            
            <div class="profile-section">
                <div class="time-date">
                    <span id="current-time"><%= currentTime %></span>
                    <span id="current-date"><%= currentDate %></span>
                </div>
                
                <% if (isLoggedIn) { %>
                <!-- Profile Icon with Dropdown -->
                <div class="profile-dropdown">
                    <div class="profile-icon">
                        <i class="fas fa-building"></i>
                        <span class="profile-name"><%= username %></span>
                        <% if (visitCount > 0) { %>
                        <span class="visit-badge">
                            <i class="fas fa-eye"></i> <%= visitCount %>
                        </span>
                        <% } %>
                        <i class="fas fa-chevron-down dropdown-arrow"></i>
                    </div>
                    <div class="dropdown-menu">
                        <a href="companyprofile.jsp" class="dropdown-item">
                            <i class="fas fa-user"></i> My Profile
                        </a>
                        <a href="post_internship.jsp" class="dropdown-item">
                            <i class="fas fa-plus-circle"></i> Post New Internship
                        </a>
                        <a href="generate_applications_xml.jsp" class="dropdown-item">
                            <i class="fas fa-users"></i> View Applications
                        </a>
                        <hr class="dropdown-divider">
                        <a href="authservlet?action=logout" class="dropdown-item logout">
                            <i class="fas fa-sign-out-alt"></i> Log Out
                        </a>
                    </div>
                </div>
                <% } else { %>
                <!-- Login Button -->
                <div class="login-section">
                    <a href="login.jsp" class="login-button">
                        <i class="fas fa-sign-in-alt"></i>v
                        <span>Login / Sign Up</span>
                    </a>
                </div>
                <% } %>
            </div>
        </div>
    </div>
    
    <hr class="headingline">
    
    <div class="main-content">
        <% if (isLoggedIn) { %>
            <!-- Welcome Section -->
            <div class="welcome-section">
                <div class="welcome-ticker">
                    <div class="ticker-text">
                        🏢 Welcome back, <%= username %>! Manage your internships and find talented candidates.
                    </div>
                    <p id="timeMessage" style="margin-top:10px; font-weight:500; margin-left: 50px;"></p>
                </div>
            </div>
            
            <% if (deleteMessage != null) { %>
                <div id="deleteMsg" class="delete-message <%= deleteMessage.contains("success") ? "" : "error" %>">
                    <i class="fas <%= deleteMessage.contains("success") ? "fa-check-circle" : "fa-exclamation-triangle" %>"></i>
                    <%= deleteMessage %>
                </div>
            <% } %>
            
            <div class="quick-actions">
                <a href="post_internship.jsp" class="action-btn">
                    <i class="fas fa-plus-circle"></i>
                    Post New Internship
                </a>
                <a href="generate_applications_xml.jsp" class="action-btn">
                    <i class="fas fa-users"></i>
                    View All Applications
                </a>
                <a href="http://localhost:8081/oipwtt/profile" class="action-btn">
                    <i class="fas fa-edit"></i>
                    Update Company Profile
                </a>
            </div>
            
            <div class="live-internships-section">
                <div class="section-header">
                    <div>
                        <h2 class="section-title">
                            <i class="fas fa-briefcase" style="color: var(--primary-blue);"></i>
                            My Posted Internships
                        </h2>
                        <p class="section-subtitle">You have posted <%= totalInternships %> internship(s)</p>
                    </div>
                </div>
                
                <div class="live-internships-grid" id="internshipsGrid">
                    <% if (companyInternships.size() > 0) { %>
                        <% for (Map<String, Object> internship : companyInternships) { 
                            String description = (String) internship.get("description");
                            if (description != null && description.length() > 120) {
                                description = description.substring(0, 120) + "...";
                            }
                            String status = (String) internship.get("status");
                            if (internship.get("deadline") != null) {
                                java.util.Date deadline = (java.util.Date) internship.get("deadline");
                                if (deadline.before(currentDateObj)) {
                                    status = "Expired";
                                }
                            }
                        %>
                        <div class="company-internship-card" id="internship-<%= internship.get("id") %>">
                            <div class="card-header-company">
                                <h3><%= internship.get("title") %></h3>
                                <span class="internship-status status-<%= status.toLowerCase() %>">
                                    <i class="fas fa-<%= status.equals("Active") ? "check-circle" : "clock" %>"></i>
                                    <%= status %>
                                </span>
                            </div>
                            <div class="live-card-body">
                                <p class="location">
                                    <i class="fas fa-map-marker-alt"></i> 
                                    <%= internship.get("location") != null ? internship.get("location") : "Location not specified" %>
                                </p>
                                <p>
                                    <i class="fas fa-clock"></i> 
                                    <%= internship.get("type") %> • <%= internship.get("duration") %>
                                </p>
                                <p>
                                    <i class="fas fa-users"></i> 
                                    <%= internship.get("openings") %> <%= Integer.parseInt(internship.get("openings").toString()) > 1 ? "Openings" : "Opening" %>
                                </p>
                                <p class="stipend-info">
                                    <i class="fas fa-money-bill-wave"></i> 
                                    <%= internship.get("stipend_type") %>
                                    <% if (internship.get("amount") != null) { %>
                                        - ₹<%= internship.get("amount") %>
                                    <% } %>
                                </p>
                                <% if (description != null) { %>
                                    <div class="description-preview">
                                        <i class="fas fa-quote-left" style="font-size: 10px; opacity: 0.5;"></i>
                                        <%= description %>
                                    </div>
                                <% } %>
                            </div>
                            <div class="live-card-footer">
                                <span class="deadline-badge">
                                    <i class="fas fa-calendar-alt"></i> 
                                    Deadline: <%= internship.get("deadline") != null ? internship.get("deadline") : "No deadline" %>
                                </span>
                                <div class="card-actions">
                                    <button onclick="confirmDelete(<%= internship.get("id") %>, '<%= internship.get("title") %>')" class="delete-btn">
                                        <i class="fas fa-trash-alt"></i> Delete
                                    </button>
                                    <a href="generate_applications_xml.jsp?internship_id=<%= internship.get("id") %>" class="view-applications-btn">
                                        <i class="fas fa-users"></i> View Applications
                                    </a>
                                </div>
                            </div>
                        </div>
                        <% } %>
                    <% } else { %>
                        <div id="noInternshipsMsg" class="no-internships">
                            <i class="fas fa-briefcase"></i>
                            <h3>No internships posted yet</h3>
                            <p>Start your recruitment journey by posting your first internship opportunity!</p>
                            <a href="post_internship.jsp" class="post-first-btn">
                                <i class="fas fa-plus-circle"></i> Post Your First Internship
                            </a>
                        </div>
                    <% } %>
                </div>
            </div>
            
            <div class="footer-note">
                <i class="fas fa-shield-alt"></i> Secure Company Session • Logged in since <%= currentTime %>
            </div>
            
        <% } else { %>
            <div class="welcome-section" style="background: linear-gradient(135deg, #667eea, #764ba2);">
                <h2><i class="fas fa-hand-wave"></i> Welcome to Company Dashboard!</h2>
                <p>Please login to manage your internships and find talented candidates.</p>
                <div class="session-info-card" style="background: rgba(255,255,255,0.2);">
                    <i class="fas fa-info-circle"></i> 
                    <a href="login.jsp" style="color: white; text-decoration: underline;">Login here</a> to access your company dashboard
                </div>
            </div>
        <% } %>
    </div>
    
    <jsp:include page="footer.jsp" />
    
    <script>
        let hour = new Date().getHours();
        let msg = "";

        if (hour < 12) {
            msg = "Good morning! Time to review new applications 🌅";
        } else if (hour < 18) {
            msg = "Good afternoon! Keep managing your internship posts ☀️";
        } else {
            msg = "Good evening! Check for new student applications 🌙";
        }
        document.getElementById("timeMessage").innerText = msg;
        
        let sessionData = {
            username: "<%= username %>",
            role: "<%= role != null ? role : "Company" %>",
            currentLogin: "<%= formattedCurrentLogin %>",
            lastLogin: "<%= formattedLastLogin %>",
            visits: "<%= visitCount != 0 ? visitCount : 1 %>",
            sessionId: "<%= shortSessionId %>",
            userId: "<%= userId != null ? userId : "N/A" %>"
        };

        function confirmDelete(internshipId, internshipTitle) {
            if (confirm("Are you sure you want to delete the internship: \"" + internshipTitle + "\"?\n\nThis action cannot be undone and will remove all applications for this internship.")) {
                window.location.href = "companyhome.jsp?delete_id=" + internshipId;
            }
        }
        const deleteMsg = document.getElementById("deleteMsg");
        if (deleteMsg) {
            setTimeout(() => {
                deleteMsg.style.transition = "opacity 0.5s ease";
                deleteMsg.style.opacity = "0";
                setTimeout(() => deleteMsg.remove(), 500);
            }, 3000); // 3 seconds
        }
        const sessionContainer = document.getElementById("sessionContainer");
        if (sessionContainer) {
            sessionContainer.innerHTML = `
                <div class="session-info">
                    <p><i class="fas fa-user"></i> <strong>${sessionData.username}</strong></p>
                    <p><i class="fas fa-briefcase"></i> Role: ${sessionData.role}</p>
                    <p><i class="fas fa-clock"></i> Login: ${sessionData.currentLogin}</p>
                    <p><i class="fas fa-history"></i> Last: ${sessionData.lastLogin}</p>
                    <p><i class="fas fa-eye"></i> Visits: ${sessionData.visits}</p>
                    <p><i class="fas fa-id-card"></i> Session: ${sessionData.sessionId}</p>
                </div>
            `;
        }
        const noInternshipsMsg = document.getElementById("noInternshipsMsg");
        if (noInternshipsMsg) {
            setTimeout(() => {
                noInternshipsMsg.style.transition = "opacity 0.5s ease";
                noInternshipsMsg.style.opacity = "0";
                setTimeout(() => noInternshipsMsg.remove(), 500);
            }, 4000);
        }
    </script>
</body>
</html>