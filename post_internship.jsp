

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Post Internship</title>

<!-- COMMON AUTH STYLES -->
<link rel="stylesheet" href="auth-styles.css">

<!-- ICONS -->
<link rel="stylesheet" href="css/all.min.css">

<style>
/* ONLY EXTRA STYLES (not duplicating auth styles) */

.container {
    max-width: 750px; /* slightly wider for form */
}

.form-row {
    display: flex;
    gap: 15px;
}

.form-row .form-group {
    flex: 1;
}

textarea {
    width: 100%;
    padding: 14px;
    border-radius: 8px;
    border: 2px solid var(--border-color);
    resize: vertical;
}

.message {
    margin: 15px 25px;
    padding: 12px;
    border-radius: 8px;
    text-align: center;
}

.success {
    background: #d4edda;
    color: #155724;
}

</style>
</head>

<body>

<div class="container">

    <!-- HEADER -->
    <div class="header">
        <h1><i class="fas fa-plus-circle"></i> Post Internship</h1>
        <p>Create a new internship opportunity</p>
    </div>

    <!-- SUCCESS MESSAGE (STATIC PREVIEW) -->
    <% if(request.getAttribute("success") != null) { %>
    <div class="message success">
        <i class="fas fa-check-circle"></i> <%= request.getAttribute("success") %>
    </div>
<% } %>

<% if(request.getAttribute("error") != null) { %>
    <div class="message" style="background:#f8d7da;color:#721c24;">
        <i class="fas fa-times-circle"></i> <%= request.getAttribute("error") %>
    </div>
<% } %>
<% if(request.getAttribute("success") != null) { %>
<script>
    setTimeout(function(){
        window.location.href = "studenthome.jsp";
    }, 3000);
</script>
<% } %>

    <!-- FORM -->
   <form method="POST" action="postinternship">
    <input type="hidden" name="company_id" value="<%= session.getAttribute("user_id") %>">

        <div class="form-section">

            <div class="form-group">
                <label><i class="fas fa-building"></i> Company Name *</label>
                <input type="text" placeholder="Enter company name" >
            </div>

            <div class="form-group">
                <label><i class="fas fa-briefcase"></i> Internship Title *</label>
                <input type="text" name="title" placeholder="Frontend Developer Intern" required>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label><i class="fas fa-calendar-alt"></i> Internship Type *</label>
                    <select name="type" required>
                        <option>Select type</option>
                        <option>Full-time</option>
                        <option>Part-time</option>
                        <option>Remote</option>
                        <option>Hybrid</option>
                    </select>
                </div>

                <div class="form-group">
                    <label><i class="fas fa-clock"></i> Duration *</label>
                    <select name="duration" required>
                        <option>Select duration</option>
                        <option>1 Month</option>
                        <option>3 Months</option>
                        <option>6 Months</option>
                        <option>1 Year</option>
                    </select>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label><i class="fas fa-money-bill-wave"></i> Stipend Type *</label>
                      <select name="stipend_type" id="stipendType" required>
                        <option value="" disabled selected>Select type</option>
                        <option value="Paid">Paid</option>
                        <option value="Unpaid">Unpaid</option>
                        <option value="Stipend">Stipend</option>
                      </select>
                </div>

                <div class="form-group" id="amountGroup" style="display:none;">
                    <label id="amountLabel"><i class="fas fa-dollar-sign"></i> Amount/Month *</label>
                    <input  name="amount" type="number" placeholder="Enter amount">
                </div>
            </div>

            <div class="form-group">
                <label><i class="fas fa-gift"></i> Benefits</label>
                <textarea name="benefits" placeholder="Certificate, LOR, etc."></textarea>
            </div>

            <div class="form-group">
                <label><i class="fas fa-tools"></i> Required Skills *</label>
                <textarea name="skills" placeholder="HTML, CSS, JS" required></textarea>
            </div>

            <div class="form-group">
                <label><i class="fas fa-align-left"></i> Job Description *</label>
                <textarea name="description"placeholder="Describe the internship..." required></textarea>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label><i class="fas fa-users"></i> Openings *</label>
                    <input type="number"  name="openings" placeholder="5" required>
                </div>

                <div class="form-group">
                    <label><i class="fas fa-calendar-times"></i> Deadline *</label>
                    <input type="date" name="deadline" required>
                </div>
            </div>

            <div class="form-group">
                <label><i class="fas fa-map-marker-alt"></i> Location *</label>
                <input type="text" name="location" placeholder="Chennai / Remote" required>
            </div>

        </div>

        <!-- ACTION BUTTON -->
        <div class="form-actions">
            <button type="submit" class="button">
                <i class="fas fa-paper-plane"></i> Post Internship
            </button>
        </div>
        <br/>
    </form>

</div>

<script>
const stipend = document.getElementById("stipendType");
const amountGroup = document.getElementById("amountGroup");
const amountLabel = document.getElementById("amountLabel");

stipend.addEventListener("change", function(){
    if(this.value === "Paid"){
        amountGroup.style.display = "block";
        amountLabel.innerHTML = '<i class="fas fa-dollar-sign"></i> Amount *';
    } 
    else if(this.value === "Stipend"){
        amountGroup.style.display = "block";
        amountLabel.innerHTML = '<i class="fas fa-dollar-sign"></i> Amount / Month *';
    } 
    else {
        amountGroup.style.display = "none";
    }
});
 
</script>

</body>
</html>

