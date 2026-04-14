<%@ page import="java.util.Map" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    HttpSession httpSession = request.getSession(false);
    Integer userId = (httpSession != null) ? (Integer) httpSession.getAttribute("user_id") : null;

    
    // Get profile data from Servlet
    Map<String, Object> profileData = (Map<String, Object>) request.getAttribute("profileData");
    boolean profileExists = request.getAttribute("profileExists") != null
                            ? (Boolean) request.getAttribute("profileExists")
                            : false;

    // Safe getters for each field
    String fullName = profileExists && profileData.get("full_name") != null ? profileData.get("full_name").toString() : "";
    String email = profileExists && profileData.get("email") != null ? profileData.get("email").toString() : "";
    String phone = profileExists && profileData.get("phone") != null ? profileData.get("phone").toString() : "";
    String location = profileExists && profileData.get("location") != null ? profileData.get("location").toString() : "";
    String university = profileExists && profileData.get("university") != null ? profileData.get("university").toString() : "";
    String degree = profileExists && profileData.get("degree") != null ? profileData.get("degree").toString() : "";
    String major = profileExists && profileData.get("major") != null ? profileData.get("major").toString() : "";
    String graduationYear = profileExists && profileData.get("graduation_year") != null ? profileData.get("graduation_year").toString() : "";
    String skills = profileExists && profileData.get("technical_skills") != null ? profileData.get("technical_skills").toString() : "";
    String softSkills = profileExists && profileData.get("soft_skills") != null ? profileData.get("soft_skills").toString() : "";
    String resumePath = profileExists && profileData.get("resume_path") != null ? profileData.get("resume_path").toString() : "";
    String availability = profileExists && profileData.get("availability") != null ? profileData.get("availability").toString() : "";
    String startDate = profileExists && profileData.get("start_date") != null ? profileData.get("start_date").toString() : "";
    String objective = profileExists && profileData.get("objective") != null ? profileData.get("objective").toString() : "";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Profile</title>
    <link rel="stylesheet" href="auth-styles.css">
    <link rel="stylesheet" href="css/all.min.css">
    
</head>
<body>
<div class="profile-container">

    <!-- HEADER -->
    <div class="form-header">
        <h1><i class="fas fa-user-graduate"></i> Student Profile</h1>
        <p>Complete your profile to apply for internships</p>
    </div>
    
    <!-- FORM START -->

        <!-- PERSONAL INFO -->
        <div class="form-section">
            <h3>Personal Information</h3>
            <div class="form-row">
                <div class="form-group">
                    <label>Full Name *</label>
                    <input type="text" name="fullName" required value="<%= fullName %>">
                </div>
                <div class="form-group">
                    <label>Email *</label>
                    <input type="email" name="email" required value="<%= email %>">
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label>Phone *</label>
                    <input type="text" name="phone" required value="<%= phone %>">
                </div>
                <div class="form-group">
                    <label>Location *</label>
                    <input type="text" name="location" required value="<%= location %>">
                </div>
            </div>
        </div>

        <!-- EDUCATION -->
        <div class="form-section">
            <h3>Education</h3>
            <div class="form-row">
                <div class="form-group">
                    <label>University *</label>
                    <input type="text" name="university" required value="<%= university %>">
                </div>
                <div class="form-group">
                    <label>Degree *</label>
                    <select name="degree" required>
                        <option value="">Select</option>
                        <option value="Bachelor" <%= "Bachelor".equals(degree) ? "selected" : "" %>>Bachelor</option>
                        <option value="Master" <%= "Master".equals(degree) ? "selected" : "" %>>Master</option>
                        <option value="Diploma" <%= "Diploma".equals(degree) ? "selected" : "" %>>Diploma</option>
                    </select>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label>Major *</label>
                    <input type="text" name="major" required value="<%= major %>">
                </div>
                <div class="form-group">
                    <label>Graduation Year *</label>
                    <select name="graduationYear" required>
                        <option value="">Select</option>
                        <option value="2024" <%= "2024".equals(graduationYear) ? "selected" : "" %>>2024</option>
                        <option value="2025" <%= "2025".equals(graduationYear) ? "selected" : "" %>>2025</option>
                        <option value="2026" <%= "2026".equals(graduationYear) ? "selected" : "" %>>2026</option>
                        <option value="2027" <%= "2027".equals(graduationYear) ? "selected" : "" %>>2027</option>
                    </select>
                </div>
            </div>
        </div>

        <!-- SKILLS -->
        <div class="form-section">
            <h3>Skills</h3>
            <div class="form-group">
                <label>Technical Skills *</label>
                <input type="text" name="skills" placeholder="Java, Python, SQL" required value="<%= skills %>">
            </div>
            <div class="form-group">
                <label>Soft Skills</label>
                <input type="text" name="softSkills" placeholder="Communication, Leadership" value="<%= softSkills %>">
            </div>
        </div>

        <!-- RESUME -->
        <div class="form-section">
            <h3>Upload Resume</h3>
            <div class="form-group">
                <input type="file" name="resume" accept=".pdf,.doc,.docx">
                <% if (resumePath != null && !resumePath.isEmpty()) { %>
                    <p>Current Resume: <a href="<%= resumePath %>" target="_blank">View</a></p>
                <% } %>
            </div>
        </div>

        <!-- AVAILABILITY -->
        <div class="form-section">
            <h3>Availability</h3>
            <div class="form-row">
                <div class="form-group">
                    <label>Type *</label>
                    <select name="availability" required>
                        <option value="">Select</option>
                        <option value="Full-time" <%= "Full-time".equals(availability) ? "selected" : "" %>>Full-time</option>
                        <option value="Part-time" <%= "Part-time".equals(availability) ? "selected" : "" %>>Part-time</option>
                        <option value="Remote" <%= "Remote".equals(availability) ? "selected" : "" %>>Remote</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Start *</label>
                    <select name="startDate" required>
                        <option value="">Select</option>
                        <option value="Immediately" <%= "Immediately".equals(startDate) ? "selected" : "" %>>Immediately</option>
                        <option value="1 Month" <%= "1 Month".equals(startDate) ? "selected" : "" %>>1 Month</option>
                        <option value="3 Months" <%= "3 Months".equals(startDate) ? "selected" : "" %>>3 Months</option>
                    </select>
                </div>
            </div>
        </div>

        <!-- OBJECTIVE -->
        <div class="form-section">
            <h3>Career Objective</h3>
            <div class="form-group">
                <input type="text" name="objective" placeholder="Your career goal..." required value="<%= objective %>">
            </div>
        </div>

        <!-- ACTIONS -->
        <div class="form-section" style="display: flex; gap: 10px; align-items: center;">
    <!-- Save <!-- SAVE PROFILE FORM -->
<form method="POST" action="profile" enctype="multipart/form-data">
    <!-- all input fields including fullName -->
    <button type="submit" name="action" value="save">Save Profile</button>
</form>

<!-- DELETE PROFILE FORM -->
<form method="POST" action="profile">
    <input type="hidden" name="action" value="delete">
    <button type="submit" onclick="return confirm('Are you sure you want to delete your profile?');">
        Delete Profile
    </button>
</form>
           


</div>
    
</div>

</body>
</html>