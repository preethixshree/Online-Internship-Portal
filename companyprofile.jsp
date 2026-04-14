<%@ page import="java.sql.ResultSet" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    ResultSet profileData = (ResultSet) request.getAttribute("profileData");
    String companyName = "", industry = "", email = "", phone = "", address = "", logoPath = "";

    if (profileData != null) {
        companyName = profileData.getString("company_name");
        industry = profileData.getString("industry");
        email = profileData.getString("email");
        phone = profileData.getString("phone");
        address = profileData.getString("address");
        logoPath = profileData.getString("logo_path");
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Company Profile</title>
<link rel="stylesheet" href="auth-styles.css">
<link rel="stylesheet" href="css/all.min.css">
</head>
<body>
<div class="profile-container">

    <div class="profile-form-container">
        <div class="form-header">
            <h1><i class="fas fa-building"></i> Company Profile</h1>
            <p>Complete your company profile to post internships</p>
        </div>

        <form id="companyProfileForm" method="POST" action="profile" enctype="multipart/form-data" class="profile-form">
            <input type="hidden" name="id" value="<%= session.getAttribute("userId") %>">

            <div class="form-section">
                <h2>Basic Information</h2>
                <br/>
                <div class="form-row">
                    <div class="form-group">
                        <label for="companyName">Company Name *</label>
                        <input type="text" id="companyName" name="companyName" required placeholder="Enter company name" value="<%= companyName %>">
                    </div>

                    <div class="form-group">
                        <label for="industry">Industry *</label>
                        <select id="industry" name="industry" required>
                            <option value="">Select industry</option>
                            <option value="technology" <%= "technology".equalsIgnoreCase(industry) ? "selected" : "" %>>Technology</option>
                            <option value="finance" <%= "finance".equalsIgnoreCase(industry) ? "selected" : "" %>>Finance & Banking</option>
                            <option value="healthcare" <%= "healthcare".equalsIgnoreCase(industry) ? "selected" : "" %>>Healthcare</option>
                            <option value="education" <%= "education".equalsIgnoreCase(industry) ? "selected" : "" %>>Education</option>
                            <option value="retail" <%= "retail".equalsIgnoreCase(industry) ? "selected" : "" %>>Retail & E-commerce</option>
                            <option value="other" <%= "other".equalsIgnoreCase(industry) ? "selected" : "" %>>Other</option>
                        </select>
                    </div>
                </div>
            </div>

            <div class="form-section">
                <h2>Contact Information</h2>
                <br/>
                <div class="form-row">
                    <div class="form-group">
                        <label for="email">Email Address *</label>
                        <input type="email" id="email" name="email" required placeholder="contact@company.com" value="<%= email %>">
                    </div>

                    <div class="form-group">
                        <label for="phone">Phone Number</label>
                        <input type="tel" id="phone" name="phone" placeholder="+1 (555) 123-4567" value="<%= phone %>">
                    </div>
                </div>

                <div class="form-group">
                    <label for="address">Address *</label>
                    <input type="text" id="address" name="address" required placeholder="Street address" value="<%= address %>">
                </div>
            </div>

            <div class="form-section">
                <h2>Company Logo</h2>
                <br/>
                <div class="logo-upload-container">
                    <div class="logo-preview" id="logoPreviewContainer">
                        <% if (logoPath != null && !logoPath.isEmpty()) { %>
                            <img id="logoPreview" src="<%= logoPath %>" alt="Logo Preview">
                        <% } else { %>
                            <div class="logo-placeholder" id="logoPlaceholder">
                                <i class="fas fa-building"></i>
                                <span>Logo Preview</span>
                            </div>
                        <% } %>
                    </div>
                    <label class="upload-btn">
                        <input type="file" id="logo" name="logo" accept="image/*" style="display: none;">
                        <i class="fas fa-upload"></i> Upload Logo
                    </label>
                </div>
            </div>
             <div class="form-section" style="display: flex; gap: 10px; align-items: center;">
        <button type="submit" name="action" value="save" class="save-btn">
            <i class="fas fa-check-circle"></i> Save Profile
        </button>

        <button type="submit" name="action" value="delete" class="delete-btn"
                onclick="return confirm('Are you sure you want to delete your profile?');">
            <i class="fas fa-trash"></i> Delete Profile
        </button>
             
        </form>
    </div>
</div>

<script src="profile_script.js"></script>
</body>
</html>