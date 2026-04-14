<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat" %>
<%@ page import="java.net.URLDecoder" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.intern.dbconnection" %>

<%
     
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    // ===== Date and Time =====
    java.util.Date now = new java.util.Date();
    SimpleDateFormat timeFormat = new SimpleDateFormat("hh:mm:ss a");
    String currentTime = timeFormat.format(now);
    
    SimpleDateFormat dateFormat = new SimpleDateFormat("EEEE, dd MMM yyyy");
    String currentDate = dateFormat.format(now);

    // ===== Welcome message from cookies =====
    String welcomeMessage = "Welcome!";
    Cookie[] cookies = request.getCookies();
    if (cookies != null) {
        for (Cookie cookie : cookies) {
            if ("welcome_message".equals(cookie.getName())) {
                welcomeMessage = URLDecoder.decode(cookie.getValue(), "UTF-8");
            }
        }
    }

    // ===== Session info check =====
    boolean isLoggedIn = session.getAttribute("username") != null;
    String username = isLoggedIn ? (String) session.getAttribute("username") : "Guest";
    
    // ===== Get session attributes from AuthServlet =====
    //String currentLogin = (String) session.getAttribute("current_login_time");
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


    // Store updated value back in session
    session.setAttribute("visit_count", visitCount);
    // ===== Format dates for display =====
    String formattedCurrentLogin = currentTime;
    String formattedLastLogin = (lastLogin != null && !lastLogin.trim().isEmpty()) ? lastLogin : "First time login";
    
    if (lastLogin != null && !lastLogin.equals("First time login")) {
        try {
            formattedLastLogin = lastLogin;
        } catch (Exception e) {
            formattedLastLogin = lastLogin;
        }
    }
    
    // ===== Session ID for display =====
    String hexSessionId = session.getId();
    String shortSessionId = hexSessionId != null && hexSessionId.length() > 8 ? 
        hexSessionId.substring(0, 8) + "..." : (hexSessionId != null ? hexSessionId : "N/A");
%>

<%! 
    String[] internshipTitles = {
        "Python Development",
        "Internet of Things",
        "Software Development",
        "Mobile App Development",
        "Full Stack Development",
        "Cyber Security",
        "Artificial Intelligence",
        "Data Science & Analytics",
        "Cloud Computing & DevOps",
        "Machine Learning & Advanced Data"
    };

    String[] internshipDescriptions = {
        "Master Python programming, Django/Flask frameworks, automation scripts, and build real-world applications.",
        "Learn IoT architecture, sensor networks, embedded systems, and build smart device projects.",
        "Master SDLC, Agile methodologies, coding best practices, and enterprise software development.",
        "Build iOS & Android apps using React Native, Flutter, Swift, and Kotlin.",
        "Master frontend and backend technologies with databases and deployment.",
        "Learn ethical hacking, network security, cryptography, and threat analysis.",
        "Explore AI algorithms, neural networks, NLP, and computer vision.",
        "Master data analysis, visualization, and statistical modeling using Python/R.",
        "Learn AWS/Azure, Docker, Kubernetes, and CI/CD pipelines.",
        "Advanced ML algorithms, deep learning, and big data processing."
    };

    String[] internshipImages = {
        "pd.jpg",
        "iot.jpg",
        "sd.jpg",
        "mad.jpg",
        "fsd.jpg",
        "cs.jpg",
        "ai.jpg",
        "dsa.jpg",
        "ccd.jpg",
        "mlad.jpg"
    };
    String[] internshipBadges = {
        "Popular", "New", "", "Trending", "", "High Demand", "", "Hot", "", "Advanced"
    };
%>

<%
    // ===== FETCH LIVE INTERNSHIPS FROM DATABASE USING dbconnection CLASS =====
    List<Map<String, Object>> liveInternships = new ArrayList<>();
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        conn = dbconnection.getConnection();
        
        String sql = "SELECT i.*, u.username as company_name FROM internships i " +
                    "JOIN users u ON i.company_id = u.id " +
                    "WHERE i.status = 'Active' ORDER BY i.posted_date DESC LIMIT 10";
        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();
        
        while (rs.next()) {
            Map<String, Object> internship = new HashMap<>();

            internship.put("id", rs.getInt("id"));
            internship.put("title", rs.getString("title"));
            internship.put("company_name", rs.getString("company_name"));
            internship.put("location", rs.getString("location"));
            internship.put("type", rs.getString("type"));
            internship.put("duration", rs.getString("duration"));
            internship.put("stipend_type", rs.getString("stipend_type"));
            internship.put("amount", rs.getBigDecimal("amount"));
            internship.put("description", rs.getString("description"));
            internship.put("openings", rs.getInt("openings"));
            internship.put("deadline", rs.getDate("deadline"));

            // ✅ ADD THIS
            internship.put("posted_date", rs.getTimestamp("posted_date"));

            liveInternships.add(internship);
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        dbconnection.closeConnection(conn);
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Home - Online Internship Portal</title>
    <link rel="stylesheet" href="stylehome.css">
    <link rel="stylesheet" href="css/all.min.css">
    <script src="stylescript.js"></script>
</head>
<body>
    <div id="sidebar" class="sidebar">
    <h3>👤 Session Info</h3>
    <div id="sessionContainer"></div>
</div>

    <!-- Header Section -->
    <div class="headingbox">
        <div class="header-content">
            <div class="menu-icon" onclick="toggleSidebar()">
            <i class="fas fa-bars"></i>
            </div>
            
            <div class="headingtext">
                <i class="fas fa-graduation-cap"></i>
                Online Internship Portal
            </div>
            
            <!-- Search Bar - Now filters live internships -->
            <div class="search-container">
                <i class="fas fa-search search-icon"></i>
                <input type="text" class="search-bar" id="liveSearchInput" placeholder="Filter live internships by title, company, location..." autocomplete="off">
                <i class="fas fa-times clear-icon" id="clearSearchBtn" onclick="clearSearch()"></i>
            </div>
            
            <!-- Profile and Time Section -->
            <div class="profile-section">
                <!-- Current Time and Date -->
                <div class="time-date">
                    <span id="current-time"><%= currentTime %></span>
                    <span id="current-date"><%= currentDate %></span>
                </div>
                
                <% if (isLoggedIn) { %>
                <!-- Profile Icon with Dropdown -->
                <div class="profile-dropdown">
                    <div class="profile-icon">
                        <i class="fas fa-user-circle"></i>
                        <span class="profile-name"><%= username %></span>
                        <% if (visitCount > 0) { %>
                        <span class="visit-badge">
                            <i class="fas fa-eye"></i> <%= visitCount %>
                        </span>
                    <% } %>
                        <i class="fas fa-chevron-down dropdown-arrow"></i>
                    </div>
                    <div class="dropdown-menu">
                       <a href="http://localhost:8081/oipwtt/profile" class="dropdown-item">
                            <i class="fas fa-user"></i> My Profile
                       </a>
                        <a href="http://localhost/oipwt/applicationstatus.php?user_id=<%= userId %>&session_id=<%= session.getId() %>" class="dropdown-item">                 
                            <i class="fas fa-file-alt"></i> My Applications
                        </a>
                        <a href="feedback.jsp" class="dropdown-item">
                        <i class="fas fa-comment"></i> Give Feedback
                        </a>

                        <a href="viewfeedbacks.jsp" class="dropdown-item">
                        <i class="fas fa-bookmark"></i> View Feedbacks
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
                        <i class="fas fa-sign-in-alt"></i>
                        <span>Login / Sign Up</span>
                    </a>
                </div>
                <% } %>
            </div>
        </div>
    </div>
    
    <hr class="headingline">
    
    <!-- Main Content -->
    <div class="main-content">
        <% if (isLoggedIn) { %>
            <!-- Welcome Section with Session Info -->
            <div class="welcome-section">
                 <div class="welcome-ticker">
                 <div class="ticker-text">
                👋 Welcome back, <%= username %>!
            </div>
            <p id="timeMessage" style="margin-top:10px; font-weight:500; margin-left: 50px;"></p>
         </div>
        </div>
            
            <!-- Stats for Students -->
         
            <!-- Quick Actions -->
           
            
            <!-- Recent Activity -->
           
        <% } else { %>
            <!-- Guest Welcome Message -->
            <div class="welcome-section" style="background: linear-gradient(135deg, #667eea, #764ba2);">
                <h2><i class="fas fa-hand-wave"></i> Welcome to Online Internship Portal!</h2>
                <p>Discover amazing internship opportunities and kickstart your career.</p>
                <div class="session-info-card" style="background: rgba(255,255,255,0.2);">
                    <i class="fas fa-info-circle"></i> 
                    <a href="login.jsp" style="color: white; text-decoration: underline;">Login here</a> to access your dashboard
                </div>
            </div>
        <% } %>
        
        <!-- Categories -->
        
        <!-- Recommended Internship Cards (Static) -->
        <div class="container">
            <div class="section-header">
                <h2 class="section-title">
                    <% if (isLoggedIn) { %>
                        Recommended For You
                    <% } else { %>
                        Featured Internships
                    <% } %>
                </h2>
            </div>
            
            <div class="card__container" id="card-container">
                <% for (int i = 0; i < internshipTitles.length; i++) { 
                    String title = internshipTitles[i];
                    String desc = internshipDescriptions[i];
                    String img = internshipImages[i];
                    String badge = internshipBadges[i];
                %>
                <article class="card__article">
                    <img src="images/<%= img %>" alt="<%= title %>" class="card__img">
                    <div class="card__data">
                        <h2 class="card__title"><%= title %></h2>
                        <span class="card__description"><%= desc %></span>
                        <% if (isLoggedIn) { %>
                            <a href="#" class="card__button">Apply Now</a>
                        <% } else { %>
                            <a href="login.jsp" class="card__button login-to-view">Login to Apply</a>
                        <% } %>
                    </div>
                    <% if (!badge.isEmpty()) { %>
                        <div class="card__badge"><%= badge %></div>
                    <% } %>
                </article>
                <% } %>
            </div>
        </div>

        <!-- LIVE INTERNSHIPS SECTION with Client-Side Filtering and AJAX Sorting -->
<div class="live-internships-section">
    <div class="section-header">
        <div>
            <h2 class="section-title">
                <i class="fas fa-briefcase" style="color: var(--primary-blue);"></i>
                Live Internships from Companies
            </h2>
            <p class="section-subtitle" id="resultsCount">Showing <%= liveInternships.size() %> internships</p>
        </div>
        <div class="search-results-header" id="searchResultsHeader" style="display: none;">
            <span class="search-info">
                <i class="fas fa-search"></i> 
                Filtered: "<span id="searchTerm"></span>"
            </span>
            <button class="clear-search" onclick="clearSearch()">
                <i class="fas fa-times"></i> Clear
            </button>
        </div>
    </div>
    
    <!-- New Filter Bar for Sorting -->
    <!-- New Filter Bar for Sorting -->
<div class="filter-bar">
    <div class="filter-label">
        <i class="fas fa-sort-amount-down"></i>
        <span>Sort by:</span>
    </div>
    <div class="filter-options">
        <button class="filter-btn active" onclick="sortInternships('latest')" id="sortLatest">
            <i class="fas fa-clock"></i> Latest
            <span class="sort-indicator"><i class="fas fa-arrow-down"></i></span>
        </button>
        <button class="filter-btn" onclick="sortInternships('oldest')" id="sortOldest">
            <i class="fas fa-history"></i> Oldest
            <span class="sort-indicator"><i class="fas fa-arrow-up"></i></span>
        </button>
        <div class="filter-divider"></div>
        <button class="filter-btn" onclick="sortInternships('az')" id="sortAZ">
            <i class="fas fa-sort-alpha-down"></i> A-Z
        </button>
        <button class="filter-btn" onclick="sortInternships('za')" id="sortZA">
            <i class="fas fa-sort-alpha-up"></i> Z-A
        </button>
    </div>
    <div class="filter-stats">
        <i class="fas fa-sync-alt"></i>
        <span id="sortStatus">Sorted by Latest</span>
    </div>
</div>
    
    <!-- Internships Grid -->
    <div class="live-internships-grid" id="internshipsGrid">
        <% if (liveInternships.size() > 0) { %>
            <% for (Map<String, Object> internship : liveInternships) { 
                String description = (String) internship.get("description");
                if (description != null && description.length() > 120) {
                    description = description.substring(0, 120) + "...";
                }
            %>
            <div class="live-internship-card" 
                 data-id="<%= internship.get("id") %>"
                 data-title="<%= internship.get("title") %>"
                 data-company="<%= internship.get("company_name") %>"
                 data-location="<%= internship.get("location") != null ? internship.get("location") : "" %>"
                 data-description="<%= internship.get("description") != null ? internship.get("description") : "" %>"
                 data-posted-date="<%= internship.get("posted_date") != null ? internship.get("posted_date") : "" %>">
                <div class="live-card-header">
                    <h3><%= internship.get("title") %></h3>
                    <span class="company-badge">
                        <i class="fas fa-building"></i> <%= internship.get("company_name") %>
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
                        <% if (internship.get("deadline_formatted") != null) { %>
                            Deadline: <%= internship.get("deadline_formatted") %>
                        <% } else { %>
                            No deadline
                        <% } %>
                    </span>
                    <a href="intdesc.jsp?id=<%= internship.get("id") %>" class="view-details-btn">
                        View Details <i class="fas fa-arrow-right"></i>
                    </a>
                </div>
            </div>
            <% } %>
        <% } else { %>
            <div class="no-internships-message" id="noInternshipsMsg">
                <i class="fas fa-briefcase"></i>
                <h3>No live internships available</h3>
                <p>Check back later for new opportunities from companies!</p>
            </div>
        <% } %>
    </div>
</div>


    
    <% if (isLoggedIn) { %>
    <div class="footer-note">
        <i class="fas fa-shield-alt"></i> Secure Session • Logged in since <%= currentTime %>
    </div>
    <% } %>
    <!-- CHAT ICON -->
    <div id="chatIcon" onclick="toggleChat()">
        <i class="fas fa-comments"></i>
    </div>

    <!-- CHAT WINDOW -->
    <div id="chatWindow">
        <iframe src="chatbot.html"></iframe>
    </div>
    <jsp:include page="footer.jsp" />
<script>
    let hour = new Date().getHours();

let msg = "";

if (hour < 12) {
    msg = "New opportunities waiting for you today 🚀";
} else if (hour < 18) {
    msg = "Explore internships while companies are active 👨‍💼";
} else {
    msg = "Some deadlines may be closing soon ⚠️";
}document.getElementById("timeMessage").innerText = msg;
    
let sessionData = {
    username: "<%= username %>",
    role: "<%= role != null ? role : "Student" %>",
    currentLogin: "<%= formattedCurrentLogin %>",
    lastLogin: "<%= formattedLastLogin %>",
    visits: "<%= visitCount != 0 ? visitCount : 1 %>",
    sessionId: "<%= shortSessionId %>",
    userId: "<%= userId != null ? userId : "N/A" %>"
};

function toggleChat() {
    const chatWindow = document.getElementById("chatWindow");

    if (chatWindow.style.display === "block") {
        chatWindow.style.display = "none";
    } else {
        chatWindow.style.display = "block";
    }
}

</script>
</body>
</html> 