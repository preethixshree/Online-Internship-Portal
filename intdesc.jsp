<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.intern.dbconnection" %>

<%
    // Get internship ID from URL parameter
    String internshipId = request.getParameter("id");
    if (internshipId == null || internshipId.isEmpty()) {
        response.sendRedirect("browse-internships.jsp");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    // Variables to store internship details - using only columns from internships table
    String title = "", type = "", duration = "", stipendType = "", benefits = "";
    String skills = "", description = "", location = "", status = "";
    int openings = 0, companyId = 0;
    double amount = 0.0;
    java.sql.Date deadline = null;
    Timestamp postedDate = null;
    
    // Variables for company details (from users table)
    String companyUsername = "", companyEmail = "", companyLogo = "";
    
    // Check if user is logged in
    boolean isLoggedIn = session.getAttribute("username") != null;
    String username = isLoggedIn ? (String) session.getAttribute("username") : "Guest";
    Integer userId = (Integer) session.getAttribute("user_id");
    String role = (String) session.getAttribute("role");
    
    try {
        conn = dbconnection.getConnection();
        
        // Get internship details - join with users table to get company username
        String sql = "SELECT i.*, u.username as company_username, u.email as company_email " +
                    "FROM internships i " +
                    "LEFT JOIN users u ON i.company_id = u.id " +
                    "WHERE i.id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, Integer.parseInt(internshipId));
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            // Get company username from users table
            companyUsername = rs.getString("company_username") != null ? rs.getString("company_username") : "";
            companyId = rs.getInt("company_id");
            companyEmail = rs.getString("company_email") != null ? rs.getString("company_email") : "";
            
            // Get internship details from internships table
            title = rs.getString("title") != null ? rs.getString("title") : "";
            type = rs.getString("type") != null ? rs.getString("type") : "";
            duration = rs.getString("duration") != null ? rs.getString("duration") : "";
            stipendType = rs.getString("stipend_type") != null ? rs.getString("stipend_type") : "";
            amount = rs.getDouble("amount");
            benefits = rs.getString("benefits") != null ? rs.getString("benefits") : "";
            skills = rs.getString("skills") != null ? rs.getString("skills") : "";
            description = rs.getString("description") != null ? rs.getString("description") : "";
            openings = rs.getInt("openings");
            deadline = rs.getDate("deadline");
            location = rs.getString("location") != null ? rs.getString("location") : "";
            status = rs.getString("status") != null ? rs.getString("status") : "Active";
            postedDate = rs.getTimestamp("posted_date");
            
            // Generate company logo based on company username
            if (companyUsername != null && !companyUsername.isEmpty()) {
                companyLogo = companyUsername.substring(0, 1).toUpperCase();
            } else {
                companyLogo = "C";
            }
        } else {
            // Internship not found
            response.sendRedirect("browse-internships.jsp");
            return;
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<div style='background: #f8d7da; padding: 20px; margin: 20px; border-radius: 5px;'>");
        out.println("<h3>Database Error</h3>");
        out.println("<p>" + e.getMessage() + "</p>");
        out.println("</div>");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= title %> at <%= companyUsername %> - Internship Portal</title>
    <link rel="stylesheet" href="css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        :root {
            --primary-blue: #2DA9FF;
            --dark-blue: #0B1C2D;
            --light-blue: #E6F4FF;
            --success-green: #28a745;
            --danger-red: #dc3545;
            --warning-yellow: #ffc107;
            --border-color: #ddd;
            --shadow: 0 10px 40px rgba(11, 28, 45, 0.1);
            --gradient: linear-gradient(135deg, var(--dark-blue) 0%, var(--primary-blue) 100%);
        }

        body {
            background: url('images/44.jpg') no-repeat center center fixed;
            background-size: cover;
            min-height: 100vh;
            padding: 20px;
            position: relative;
        }

        body::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.5);
            z-index: 1;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            position: relative;
            z-index: 2;
            animation: slideUp 0.5s ease;
        }

        @keyframes slideUp {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* Back Button - New Design */
        .back-button-container {
            margin-bottom: 20px;
        }
        
        .back-to-dashboard {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            background: white;
            padding: 12px 24px;
            border-radius: 50px;
            color: var(--dark-blue);
            text-decoration: none;
            font-weight: 500;
            font-size: 15px;
            box-shadow: var(--shadow);
            transition: all 0.3s ease;
        }

        .back-to-dashboard:hover {
            background: var(--primary-blue);
            color: white;
            transform: translateX(-5px);
        }

        .back-to-dashboard i {
            font-size: 16px;
        }

        /* Main Content */
        .content-wrapper {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 25px;
            align-items: start;
        }

        /* Main Card */
        .main-card {
            background: white;
            border-radius: 20px;
            box-shadow: var(--shadow);
            overflow: hidden;
        }

        .company-header {
            background: var(--gradient);
            color: white;
            padding: 30px;
            position: relative;
            overflow: hidden;
        }

        .company-header::before {
            content: '';
            position: absolute;
            top: -50%;
            right: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, transparent 70%);
            animation: rotate 20s linear infinite;
        }

        @keyframes rotate {
            from { transform: rotate(0deg); }
            to { transform: rotate(360deg); }
        }

        .company-header-content {
            display: flex;
            align-items: center;
            gap: 20px;
            position: relative;
            z-index: 2;
        }

        .company-logo {
            width: 80px;
            height: 80px;
            background: white;
            border-radius: 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 36px;
            font-weight: bold;
            color: var(--primary-blue);
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        }

        .company-header-text h1 {
            font-size: 28px;
            margin-bottom: 5px;
        }

        .company-header-text p {
            opacity: 0.9;
            font-size: 16px;
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .company-header-text p i {
            margin-right: 5px;
        }

        .content-body {
            padding: 30px;
        }

        /* Status Bar */
        .status-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: var(--light-blue);
            padding: 15px 20px;
            border-radius: 12px;
            margin-bottom: 25px;
            flex-wrap: wrap;
            gap: 10px;
        }

        .status-badge {
            padding: 8px 16px;
            border-radius: 30px;
            font-size: 13px;
            font-weight: 600;
        }

        .status-active {
            background: #d4edda;
            color: #155724;
        }

        .status-closed {
            background: #f8d7da;
            color: #721c24;
        }

        .deadline {
            color: var(--dark-blue);
            font-size: 14px;
        }

        .deadline i {
            color: var(--primary-blue);
            margin-right: 5px;
        }

        .deadline.urgent {
            color: var(--danger-red);
            font-weight: 600;
        }

        /* Section Styles */
        .section {
            margin-bottom: 30px;
        }

        .section-title {
            color: var(--dark-blue);
            font-size: 20px;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .section-title i {
            color: var(--primary-blue);
        }

        .description-text {
            color: #444;
            line-height: 1.8;
            font-size: 15px;
        }

        /* Skills Tags */
        .skills-container {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }

        .skill-tag {
            background: var(--light-blue);
            color: var(--dark-blue);
            padding: 8px 16px;
            border-radius: 30px;
            font-size: 13px;
            font-weight: 500;
            border: 1px solid transparent;
            transition: all 0.3s;
        }

        .skill-tag:hover {
            border-color: var(--primary-blue);
            transform: translateY(-2px);
        }

        /* Info Grid */
        .info-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
        }

        .info-item {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 12px;
            border-left: 4px solid var(--primary-blue);
        }

        .info-label {
            color: #666;
            font-size: 13px;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .info-value {
            color: var(--dark-blue);
            font-size: 16px;
            font-weight: 600;
        }

        .info-value small {
            font-size: 13px;
            font-weight: normal;
            color: #666;
        }

        /* Benefits List */
        .benefits-list {
            list-style: none;
        }

        .benefits-list li {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 10px 0;
            border-bottom: 1px solid var(--border-color);
            color: #444;
        }

        .benefits-list li:last-child {
            border-bottom: none;
        }

        .benefits-list li i {
            color: var(--success-green);
        }

        /* Side Card */
        .sidebar-wrapper {
            display: flex;
            flex-direction: column;
            gap: 25px;
        }
        
        .side-card {
            background: white;
            border-radius: 20px;
            box-shadow: var(--shadow);
            padding: 25px;
            position: sticky;
            top: 20px;
        }

        /* Apply Section */
        .apply-section {
            text-align: center;
            margin-bottom: 25px;
        }

        .apply-btn {
            width: 100%;
            padding: 18px;
            background: var(--gradient);
            color: white;
            border: none;
            border-radius: 12px;
            font-size: 18px;
            font-weight: 600;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            transition: all 0.3s;
            text-decoration: none;
            margin-bottom: 15px;
        }

        .apply-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(45, 169, 255, 0.3);
        }

        .apply-btn:disabled {
            opacity: 0.6;
            cursor: not-allowed;
        }

        .deadline-note {
            font-size: 13px;
            color: #666;
        }

        /* Company Info */
        .company-info-card {
            background: var(--light-blue);
            border-radius: 12px;
            padding: 20px;
            margin: 20px 0;
        }

        .company-info-item {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 10px 0;
            border-bottom: 1px solid rgba(0,0,0,0.1);
            color: var(--dark-blue);
        }

        .company-info-item:last-child {
            border-bottom: none;
        }

        .company-info-item i {
            width: 20px;
            color: var(--primary-blue);
        }

        /* Stats */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 15px;
            margin: 20px 0;
        }

        .stat-box {
            text-align: center;
            padding: 15px;
            background: #f8f9fa;
            border-radius: 12px;
        }

        .stat-number {
            font-size: 24px;
            font-weight: bold;
            color: var(--primary-blue);
        }

        .stat-label {
            font-size: 12px;
            color: #666;
        }

        /* Share Buttons */
        .share-section {
            margin-top: 25px;
        }

        .share-title {
            font-size: 14px;
            color: #666;
            margin-bottom: 10px;
        }

        .share-buttons {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }

        .share-btn {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            text-decoration: none;
            transition: all 0.3s;
            flex-shrink: 0;
        }

        .share-btn:hover {
            transform: translateY(-3px);
        }

        .share-btn.facebook { background: #1877f2; }
        .share-btn.twitter { background: #1da1f2; }
        .share-btn.linkedin { background: #0077b5; }
        .share-btn.whatsapp { background: #25d366; }

        /* Similar Internships */
        .similar-card {
            background: white;
            border-radius: 20px;
            box-shadow: var(--shadow);
            padding: 25px;
            margin-top: 0;
            width: 100%;
        }

        .similar-item {
            display: flex;
            align-items: center;
            gap: 15px;
            padding: 15px;
            border-bottom: 1px solid var(--border-color);
            cursor: pointer;
            transition: all 0.3s;
        }

        .similar-item:hover {
            background: var(--light-blue);
            transform: translateX(5px);
        }

        .similar-item:last-child {
            border-bottom: none;
        }

        .similar-logo {
            width: 40px;
            height: 40px;
            background: var(--light-blue);
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            color: var(--primary-blue);
            flex-shrink: 0;
        }

        .similar-info {
            flex: 1;
            min-width: 0;
        }

        .similar-info h4 {
            color: var(--dark-blue);
            font-size: 15px;
            margin-bottom: 3px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .similar-info p {
            color: #666;
            font-size: 12px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        /* Alert Messages */
        .alert {
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .alert-warning {
            background: #fff3cd;
            color: #856404;
            border-left: 4px solid var(--warning-yellow);
        }

        .alert-success {
            background: #d4edda;
            color: #155724;
            border-left: 4px solid var(--success-green);
        }

        /* Modal Styles */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5);
            animation: fadeIn 0.3s ease;
        }

        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        .modal-content {
            background-color: white;
            margin: 15% auto;
            padding: 0;
            border-radius: 20px;
            width: 90%;
            max-width: 500px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            animation: slideDown 0.3s ease;
        }

        @keyframes slideDown {
            from {
                transform: translateY(-50px);
                opacity: 0;
            }
            to {
                transform: translateY(0);
                opacity: 1;
            }
        }

        .modal-header {
            background: var(--gradient);
            color: white;
            padding: 20px;
            border-radius: 20px 20px 0 0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .modal-header h3 {
            margin: 0;
            font-size: 20px;
        }

        .close-modal {
            color: white;
            font-size: 28px;
            font-weight: bold;
            cursor: pointer;
            transition: 0.3s;
        }

        .close-modal:hover {
            transform: scale(1.1);
        }

        .modal-body {
            padding: 30px;
            text-align: center;
        }

        .modal-body p {
            margin-bottom: 20px;
            color: #666;
            line-height: 1.6;
        }

        .modal-body i {
            font-size: 60px;
            color: var(--warning-yellow);
            margin-bottom: 20px;
        }

        .modal-footer {
            padding: 20px;
            text-align: center;
            border-top: 1px solid var(--border-color);
        }

        .create-profile-btn {
            background: var(--gradient);
            color: white;
            padding: 12px 30px;
            border: none;
            border-radius: 50px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: all 0.3s;
        }

        .create-profile-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(45, 169, 255, 0.3);
        }

        /* Responsive */
        @media (max-width: 768px) {
            .content-wrapper {
                grid-template-columns: 1fr;
            }
            
            .company-header-content {
                flex-direction: column;
                text-align: center;
            }
            
            .info-grid {
                grid-template-columns: 1fr;
            }
            
            .status-bar {
                flex-direction: column;
                text-align: center;
            }
            
            .side-card {
                position: static;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- Back Button - Left Arrow -->
        <div class="back-button-container">
            <a href="studenthome.jsp" class="back-to-dashboard">
                <i class="fas fa-arrow-left"></i>
                Back to Dashboard
            </a>
        </div>

        <div class="content-wrapper">
            <!-- Main Content -->
             
            <div class="main-card">
                <div class="company-header">
                    <div class="company-header-content">
                        <div class="company-logo">
                            <%= companyLogo %>
                        </div>
                        <div class="company-header-text">
                            <h1><%= title %></h1>
                            <p>
                                <span><i class="fas fa-building"></i> <%= companyUsername.isEmpty() ? "Company" : companyUsername %></span>
                                <span><i class="fas fa-map-marker-alt"></i> <%= location %></span>
                            </p>
                        </div>
                    </div>
                </div>

                <div class="content-body">
                    <!-- Status Bar -->
                    <div class="status-bar">
                        <span class="status-badge status-<%= status.toLowerCase() %>">
                            <i class="fas <%= status.equals("Active") ? "fa-check-circle" : "fa-times-circle" %>"></i>
                            <%= status %>
                        </span>
                        <span class="deadline">
                            <i class="fas fa-calendar-alt"></i>
                            Apply before: <%= deadline != null ? new SimpleDateFormat("MMMM dd, yyyy").format(deadline) : "Not specified" %>
                        </span>
                        <span>
                            <i class="fas fa-users"></i>
                            <%= openings %> <%= openings > 1 ? "Openings" : "Opening" %>
                        </span>
                    </div>

                    <!-- Description -->
                    <div class="section">
                        <h2 class="section-title">
                            <i class="fas fa-align-left"></i>
                            Internship Description
                        </h2>
                        <p class="description-text"><%= description %></p>
                    </div>

                    <!-- Skills Required -->
                    <div class="section">
                        <h2 class="section-title">
                            <i class="fas fa-code"></i>
                            Skills Required
                        </h2>
                        <div class="skills-container">
                            <% 
                                if (skills != null && !skills.isEmpty()) {
                                    String[] skillsArray = skills.split(",");
                                    for (String skill : skillsArray) {
                            %>
                                <span class="skill-tag"><%= skill.trim() %></span>
                            <% 
                                    }
                                } 
                            %>
                        </div>
                    </div>

                    <!-- Key Details Grid -->
                    <div class="section">
                        <h2 class="section-title">
                            <i class="fas fa-info-circle"></i>
                            Internship Details
                        </h2>
                        <div class="info-grid">
                            <div class="info-item">
                                <div class="info-label"><i class="fas fa-clock"></i> Duration</div>
                                <div class="info-value"><%= duration %></div>
                            </div>
                            <div class="info-item">
                                <div class="info-label"><i class="fas fa-briefcase"></i> Type</div>
                                <div class="info-value"><%= type %></div>
                            </div>
                            <div class="info-item">
                                <div class="info-label"><i class="fas fa-money-bill"></i> Stipend</div>
                                <div class="info-value">
                                    <% if (stipendType != null) { %>
                                        <% if ((stipendType.equals("Paid") || stipendType.equals("Stipend")) && amount > 0) { %>
                                            ₹<%= String.format("%,.0f", amount) %>/month
                                        <% } else { %>
                                            <%= stipendType %>
                                        <% } %>
                                    <% } else { %>
                                        Not specified
                                    <% } %>
                                </div>
                            </div>
                            <div class="info-item">
                                <div class="info-label"><i class="fas fa-calendar-week"></i> Start Date</div>
                                <div class="info-value">Immediate</div>
                            </div>
                        </div>
                    </div>

                    <!-- Benefits -->
                    <% if (benefits != null && !benefits.isEmpty()) { %>
                    <div class="section">
                        <h2 class="section-title">
                            <i class="fas fa-gift"></i>
                            Benefits & Perks
                        </h2>
                        <ul class="benefits-list">
                            <% 
                                String[] benefitsArray = benefits.split(",");
                                for (String benefit : benefitsArray) {
                            %>
                                <li><i class="fas fa-check-circle"></i> <%= benefit.trim() %></li>
                            <% } %>
                        </ul>
                    </div>
                    <% } %>

                    <!-- Posted Date -->
                    <div style="color: #999; font-size: 12px; margin-top: 20px;">
                        <i class="fas fa-clock"></i> Posted on <%= postedDate != null ? new SimpleDateFormat("MMMM dd, yyyy").format(postedDate) : "Recently" %>
                    </div>
                </div>
            </div>

            <!-- Sidebar -->
            <div class="sidebar-wrapper">
                <div class="side-card">
                    <!-- Apply Now Button -->
                    <div class="apply-section">
                    <%
                        if (status != null && status.equals("Active") && deadline != null) {

                            java.util.Date utilDeadline = new java.util.Date(deadline.getTime());
                            java.util.Date now = new java.util.Date();

                            if (utilDeadline.after(now)) {
                    %>

                            <!-- ✅ ONLY APPLY BUTTON -->
                            <button onclick="handleFreeInternship()" class="apply-btn">
                                <i class="fas fa-paper-plane"></i>
                                Apply Now
                            </button>

                            <!-- DAYS LEFT -->
                            <p class="deadline-note">
                                <i class="fas fa-hourglass-half"></i>
                                <%= (utilDeadline.getTime() - now.getTime()) / (24*60*60*1000) %> days left to apply
                            </p>

                    <%
                            } else {
                    %>
                            <button class="apply-btn" disabled>
                                <i class="fas fa-calendar-times"></i>
                                Deadline Passed
                            </button>
                    <%
                            }
                        } else {
                    %>
                            <button class="apply-btn" disabled>
                                <i class="fas fa-ban"></i>
                                Applications Closed
                            </button>
                    <%
                        }
                    %>
                    </div>
                    <!-- Stats -->
                    <div class="stats-grid">
                        <div class="stat-box">
                            <div class="stat-number"><%= openings %></div>
                            <div class="stat-label">Openings</div>
                        </div>
                        <div class="stat-box">
                            <div class="stat-number">
                                <% if (deadline != null) { 
                                    java.util.Date utilDeadline = new java.util.Date(deadline.getTime());
                                    java.util.Date now = new java.util.Date();
                                    long daysLeft = (utilDeadline.getTime() - now.getTime()) / (24*60*60*1000);
                                    out.print(daysLeft > 0 ? daysLeft : 0);
                                } else { 
                                    out.print(0);
                                } %>
                            </div>
                            <div class="stat-label">Days Left</div>
                        </div>
                    </div>
                </div>

               
            </div>
        </div>
    </div>

    <!-- Modal for Profile Creation Alert -->
    <div id="profileModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h3><i class="fas fa-exclamation-triangle"></i> Profile Required</h3>
                <span class="close-modal" onclick="closeModal()">&times;</span>
            </div>
            <div class="modal-body">
                <i class="fas fa-user-circle"></i>
                <p>You need to create your student profile before applying for internships.<br><br>
                Please complete your profile to continue with the application process.</p>
            </div>
            <div class="modal-footer">
                <a href="student_profile.jsp" class="create-profile-btn">
                    <i class="fas fa-user-plus"></i> Create Profile Now
                </a>
            </div>
        </div>
    </div>

    
    <script>
    function checkLogin() {
        let isLoggedIn = <%= session.getAttribute("user_id") != null %>;
        if (!isLoggedIn) {
            alert("Please login to apply for this internship");
            window.location.href = "login.jsp";
            return false;
        }
        return true;
    }

    function checkStudentProfile() {
        return new Promise((resolve) => {
            let xhr = new XMLHttpRequest();
            xhr.open("GET", "CheckStudentProfile.jsp", true);
            xhr.timeout = 5000; // 5 second timeout
            
            xhr.onreadystatechange = function () {
                if (xhr.readyState === 4) {
                    console.log("Response status: " + xhr.status);
                    console.log("Response text: " + xhr.responseText);
                    
                    if (xhr.status === 200) {
                        try {
                            let response = JSON.parse(xhr.responseText);
                            console.log("Profile check response:", response);
                            resolve(response.exists === true);
                        } catch (e) {
                            console.error("Failed to parse JSON:", e);
                            console.log("Raw response:", xhr.responseText);
                            resolve(false);
                        }
                    } else {
                        console.error("HTTP Error: " + xhr.status);
                        resolve(false);
                    }
                }
            };
            
            xhr.onerror = function() {
                console.error("Network error occurred");
                resolve(false);
            };
            
            xhr.ontimeout = function() {
                console.error("Request timeout");
                resolve(false);
            };
            
            xhr.send();
        });
    }

    // ✅ Apply for FREE internship
    async function handleFreeInternship() {
        console.log("handleFreeInternship called");
        
        if (!checkLogin()) return;

        let hasProfile = await checkStudentProfile();
        console.log("Has profile: " + hasProfile);

        if (!hasProfile) {
            showModal();
            return;
        }

        let internshipId = "<%= internshipId %>";
        let companyName = encodeURIComponent("<%= companyUsername %>");
        let internshipTitle = encodeURIComponent("<%= title %>");

        console.log("Submitting application for internship: " + internshipId);
        
        let xhr = new XMLHttpRequest();
        xhr.open("POST", "applyInternship.jsp", true);
        xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4) {
                console.log("Application response: " + xhr.responseText);
                try {
                    let response = JSON.parse(xhr.responseText);
                    
                    if (response.success) {
                        alert("Application submitted successfully!");
                        window.location.href = "studenthome.jsp";
                    } else {
                        alert(response.message || "Application failed");
                    }
                } catch (e) {
                    console.error("Failed to parse application response:", e);
                    alert("Error submitting application. Please try again.");
                }
            }
        };
        
        xhr.onerror = function() {
            alert("Network error. Please try again.");
        };

        xhr.send(
            "internship_id=" + internshipId +
            "&company_name=" + companyName +
            "&internship_title=" + internshipTitle
        );
    }

    
    function showModal() {
        document.getElementById("profileModal").style.display = "block";
    }

    function closeModal() {
        document.getElementById("profileModal").style.display = "none";
    }

    window.onclick = function (event) {
        let modal = document.getElementById("profileModal");
        if (event.target === modal) {
            modal.style.display = "none";
        }
    };
    
    // Debug on page load
    window.addEventListener('load', function() {
        console.log("Page loaded");
        console.log("User logged in: <%= session.getAttribute("user_id") != null %>");
        console.log("User ID: <%= session.getAttribute("user_id") %>");
        console.log("Email from session: <%= session.getAttribute("email") %>");
        
        // Optional: Test profile check on page load
        if (<%= session.getAttribute("user_id") != null %>) {
            checkStudentProfile().then(function(exists) {
                console.log("Initial profile check result: " + exists);
                if (!exists) {
                    console.log("⚠️ User has no profile! They'll see the modal when trying to apply");
                } else {
                    console.log("✓ User has profile! Good to go");
                }
            });
        }
    });

</script>
</body>
</html>