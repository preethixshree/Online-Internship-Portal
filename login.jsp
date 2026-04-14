<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login · Online Internship Portal</title>
    <link rel="stylesheet" href="css/all.min.css">
    <link rel="stylesheet" href="auth-styles.css">
</head>
<body style="background-image: url('<%= request.getContextPath() %>/images/44.jpg');">
    <div class="container">
        <div class="header">
            <h1>
                <i class="fas fa-briefcase"></i>
                Online Internship Portal
            </h1>
            <p>Welcome back! Please login to your account</p>
        </div>
        
        <div class="login-form">
            <div class="form-section">
                
                <!-- Success Message Display -->
                <%
                    String successMsg = (String) session.getAttribute("signup_success");
                    if (successMsg != null) {
                        session.removeAttribute("signup_success");
                 %>
                        <div style="background-color: #d4edda; color: #155724; padding: 12px; border-radius: 8px; margin-bottom: 20px; text-align: center; border-left: 4px solid #28a745;">
                            <i class="fas fa-check-circle" style="margin-right: 8px;"></i>
                            <%= successMsg %>
                        </div>
                <% }
                String loginError = (String) session.getAttribute("login_errors");
                if (loginError != null) {
                    session.removeAttribute("login_errors");
                    %>
                        <div style="background-color:#f8d7da; color:#721c24; padding:10px; border-radius:8px; margin-bottom:15px;">
                            <%= loginError %>
                        </div>
                    <% }
                %>
                
                <form id="loginForm" action="<%= request.getContextPath() %>/authservlet" method="post">
                    <input type="hidden" name="action" value="login">
   
                    <!-- Email Field -->
                    <div class="form-group">
                        <label for="email">
                            <i class="fas fa-envelope"></i>
                            Email Address
                        </label>
                        <input 
                            type="email" 
                            id="email" 
                            name="email" 
                            placeholder="Enter your email address" 
                            required
                        >
                    </div>
                    
                    <!-- Password Field -->
                    <div class="form-group">
                        <label for="password">
                            <i class="fas fa-lock"></i>
                            Password
                        </label>
                        <div class="password-wrapper">
                            <input 
                                type="password" 
                                id="password" 
                                name="password" 
                                placeholder="Enter your password" 
                                required
                            >
                            <i class="fas fa-eye toggle-password" onclick="togglePassword('password')"></i>
                        </div>
                    </div>

                    <!-- Role Selection Field -->
                    <div class="form-group">
                        <label for="role">
                            <i class="fas fa-user-tag"></i>
                            Login as
                        </label>
                        <select id="role" name="role" required>
                            <option value="" disabled selected>Select your role</option>
                            <option value="student">Student</option>
                            <option value="company">Company</option>
                        </select>
                        <div class="role-hint">
                            <i class="fas fa-info-circle"></i>
                            Select your account type
                        </div>
                    </div>

                    <!-- Forgot Password Link (Above Login Button) -->
                    <div class="forgot-password-container" style="text-align: right; margin-bottom: 15px;">
                        <a href="http://localhost/oip/forgot_reset.php" style="color: #007bff; text-decoration: none; font-size: 14px;">
                            <i class="fas fa-key"></i> Forgot Password?
                        </a>
                    </div>

                    <!-- Login Button -->
                    <div class="form-actions">
                        <button type="submit" class="btn-login">
                            <i class="fas fa-sign-in-alt"></i>
                            Login
                        </button>
                        <div class="signup-link">
                            Don't have an account?
                            <a href="signup.html">Sign up</a>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        // Toggle password visibility
        function togglePassword(fieldId) {
            const passwordInput = document.getElementById(fieldId);
            const toggleIcon = passwordInput.nextElementSibling;
            
            if (passwordInput.type === 'password') {
                passwordInput.type = 'text';
                toggleIcon.classList.remove('fa-eye');
                toggleIcon.classList.add('fa-eye-slash');
            } else {
                passwordInput.type = 'password';
                toggleIcon.classList.remove('fa-eye-slash');
                toggleIcon.classList.add('fa-eye');
            }
        }

        // Handle form submission
        function handleLogin(event) {
            event.preventDefault();
            
            const email = document.getElementById('email').value;
            const password = document.getElementById('password').value;
            const role = document.getElementById('role').value;
            
            // Validation
            if (!email || !password) {
                alert('Please fill in all fields');
                return;
            }
            
            if (!isValidEmail(email)) {
                alert('Please enter a valid email address');
                document.getElementById('email').classList.add('input-error');
                return;
            }
            
            if (!role) {
                alert('Please select your role');
                document.getElementById('role').classList.add('input-error');
                return;
            }
            
            // If validation passes, submit the form
            document.getElementById('loginForm').submit();
        }

        // Email validation
        function isValidEmail(email) {
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            return emailRegex.test(email);
        }

        // Input validation styling
        document.querySelectorAll('.form-group input, .form-group select').forEach(field => {
            field.addEventListener('invalid', (e) => {
                e.preventDefault();
                field.classList.add('input-error');
            });
            
            field.addEventListener('input', function() {
                this.classList.remove('input-error', 'input-valid', 'input-warning');
            });
        });

        // Dynamic placeholder based on role
        document.getElementById('role').addEventListener('change', function() {
            const emailInput = document.getElementById('email');
            if (this.value === 'company') {
                emailInput.placeholder = 'company@example.com';
            } else if (this.value === 'student') {
                emailInput.placeholder = 'student@example.edu';
            } else {
                emailInput.placeholder = 'Enter your email address';
            }
        });
       
    </script>
</body>
</html>