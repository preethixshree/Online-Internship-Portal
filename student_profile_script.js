// student_profile_script.js

// Store skills arrays
let skills = [];
let softSkills = [];

// Current profile being edited
let currentProfileId = null;
let deleteProfileId = null;

// Initialize on page load
document.addEventListener('DOMContentLoaded', function() {
    checkLoginStatus();
    loadStudentProfile();
    setupEventListeners();
    updateCharCount();
});

// Check if user is logged in
function checkLoginStatus() {
    fetch('http://localhost:9020/OnlineIP/auth?action=checkSession')
        .then(response => response.json())
        .then(data => {
            if (!data.valid) {
                window.location.href = 'http://localhost:9020/OnlineIP/login.jsp';
            }
        })
        .catch(error => console.error('Error checking session:', error));
}

// Load existing profile from server
function loadStudentProfile() {
    fetch('student-profile?action=getProfile')
        .then(response => response.json())
        .then(data => {
            if (data && !data.error && Object.keys(data).length > 0) {
                // Populate form fields
                document.getElementById('fullName').value = data.fullName || '';
                document.getElementById('email').value = data.email || '';
                document.getElementById('phone').value = data.phone || '';
                document.getElementById('location').value = data.location || '';
                document.getElementById('linkedin').value = data.linkedin || '';
                document.getElementById('university').value = data.university || '';
                document.getElementById('degree').value = data.degree || '';
                document.getElementById('major').value = data.major || '';
                document.getElementById('graduationYear').value = data.graduationYear || '';
                document.getElementById('availability').value = data.availability || '';
                document.getElementById('startDate').value = data.startDate || '';
                document.getElementById('duration').value = data.duration || '';
                document.getElementById('objective').value = data.objective || '';

                // Set email notifications
                document.getElementById('emailNotifications').checked = data.emailNotifications || false;

                // Set skills
                if (data.skills && Array.isArray(data.skills)) {
                    skills = data.skills;
                    renderSkills();
                }

                // Set soft skills
                if (data.softSkills && Array.isArray(data.softSkills)) {
                    softSkills = data.softSkills;
                    renderSoftSkills();
                }

                // Set photo if exists
                if (data.photo) {
                    const preview = document.getElementById('photoPreview');
                    const placeholder = document.getElementById('photoPlaceholder');
                    preview.src = data.photo;
                    preview.style.display = 'block';
                    placeholder.style.display = 'none';
                }

                // Update form title and button
                document.getElementById('formTitle').innerHTML = '<i class="fas fa-edit"></i> Edit Profile';
                const submitBtn = document.querySelector('.btn-primary');
                if (submitBtn) {
                    submitBtn.innerHTML = '<i class="fas fa-check-circle"></i> Update Profile';
                }
            }
        })
        .catch(error => console.error('Error loading profile:', error));
}

// Setup event listeners
function setupEventListeners() {
    // Skills input
    const skillsInput = document.getElementById('skillsInput');
    if (skillsInput) {
        skillsInput.addEventListener('keypress', function(e) {
            if (e.key === 'Enter' || e.key === ',') {
                e.preventDefault();
                addSkill();
            }
        });
    }

    // Soft skills input
    const softSkillsInput = document.getElementById('softSkillsInput');
    if (softSkillsInput) {
        softSkillsInput.addEventListener('keypress', function(e) {
            if (e.key === 'Enter' || e.key === ',') {
                e.preventDefault();
                addSoftSkill();
            }
        });
    }

    // Photo upload preview
    const photoInput = document.getElementById('photo');
    if (photoInput) {
        photoInput.addEventListener('change', handlePhotoPreview);
    }

    // Resume upload
    const resumeInput = document.getElementById('resume');
    if (resumeInput) {
        resumeInput.addEventListener('change', handleResumeUpload);
    }

    // Character counter for objective
    const objective = document.getElementById('objective');
    if (objective) {
        objective.addEventListener('input', updateCharCount);
    }

    // Form submission
    const form = document.getElementById('studentProfileForm');
    if (form) {
        form.addEventListener('submit', handleFormSubmit);
    }
}

// Handle form submit - SEND TO SERVLET
function handleFormSubmit(e) {
    e.preventDefault();

    // Validate required fields
    const requiredFields = document.querySelectorAll('[required]');
    let isValid = true;

    requiredFields.forEach(field => {
        if (!field.value.trim()) {
            field.style.borderColor = '#dc3545';
            isValid = false;
        } else {
            field.style.borderColor = '#e0e0e0';
        }
    });

    // Check terms checkbox
    const terms = document.getElementById('terms');
    if (!terms.checked) {
        alert('You must agree to the Terms of Service');
        isValid = false;
    }

    if (!isValid) {
        alert('Please fill in all required fields');
        return;
    }

    // Create FormData object
    const formData = new FormData();
    formData.append('fullName', document.getElementById('fullName').value);
    formData.append('email', document.getElementById('email').value);
    formData.append('phone', document.getElementById('phone').value);
    formData.append('location', document.getElementById('location').value);
    formData.append('linkedin', document.getElementById('linkedin').value || '');
    formData.append('university', document.getElementById('university').value);
    formData.append('degree', document.getElementById('degree').value);
    formData.append('major', document.getElementById('major').value);
    formData.append('graduationYear', document.getElementById('graduationYear').value);
    skills.forEach(skill => formData.append('skills', skill));
    softSkills.forEach(skill => formData.append('softSkills', skill));
    formData.append('availability', document.getElementById('availability').value);
    formData.append('startDate', document.getElementById('startDate').value);
    formData.append('duration', document.getElementById('duration').value);
    formData.append('objective', document.getElementById('objective').value);
    formData.append('emailNotifications', document.getElementById('emailNotifications').checked ? 'on' : 'off');

    const photoInput = document.getElementById('photo');
    if (photoInput.files.length > 0) {
        formData.append('photo', photoInput.files[0]);
    }

    const resumeInput = document.getElementById('resume');
    if (resumeInput.files.length > 0) {
        formData.append('resume', resumeInput.files[0]);
    }

    // Determine action
    const submitBtn = document.querySelector('.btn-primary');
    const isUpdate = submitBtn.innerHTML.includes('Update');
    formData.append('action', isUpdate ? 'update' : 'create');

    // Show loading state
    const originalText = submitBtn.innerHTML;
    submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Saving...';
    submitBtn.disabled = true;

    // Send to servlet
    fetch('student-profile', {
        method: 'POST',
        body: formData
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showNotification(data.success, 'success');
            loadStudentProfile();
        } else if (data.error) {
            showNotification(data.error, 'error');
        }

        submitBtn.innerHTML = originalText;
        submitBtn.disabled = false;
    })
    .catch(error => {
        console.error('Error:', error);
        showNotification('Error saving profile', 'error');
        submitBtn.innerHTML = originalText;
        submitBtn.disabled = false;
    });
}

// Save as draft
function saveAsDraft() {
    const formData = new FormData();
    formData.append('fullName', document.getElementById('fullName').value);
    formData.append('email', document.getElementById('email').value);
    formData.append('phone', document.getElementById('phone').value);
    formData.append('location', document.getElementById('location').value);
    formData.append('linkedin', document.getElementById('linkedin').value || '');
    formData.append('university', document.getElementById('university').value);
    formData.append('degree', document.getElementById('degree').value);
    formData.append('major', document.getElementById('major').value);
    formData.append('graduationYear', document.getElementById('graduationYear').value);
    skills.forEach(skill => formData.append('skills', skill));
    softSkills.forEach(skill => formData.append('softSkills', skill));
    formData.append('availability', document.getElementById('availability').value);
    formData.append('startDate', document.getElementById('startDate').value);
    formData.append('duration', document.getElementById('duration').value);
    formData.append('objective', document.getElementById('objective').value);
    formData.append('emailNotifications', document.getElementById('emailNotifications').checked ? 'on' : 'off');
    formData.append('action', 'saveDraft');

    fetch('student-profile', {
        method: 'POST',
        body: formData
    })
    .then(response => {
        if (response.redirected) window.location.href = response.url;
    })
    .catch(error => console.error('Error saving draft:', error));
}

// Add skill
function addSkill() {
    const input = document.getElementById('skillsInput');
    const skill = input.value.trim();
    if (skill && !skills.includes(skill)) {
        skills.push(skill);
        renderSkills();
        input.value = '';
    }
}

// Add soft skill
function addSoftSkill() {
    const input = document.getElementById('softSkillsInput');
    const skill = input.value.trim();
    if (skill && !softSkills.includes(skill)) {
        softSkills.push(skill);
        renderSoftSkills();
        input.value = '';
    }
}

// Remove skill
function removeSkill(skill) {
    skills = skills.filter(s => s !== skill);
    renderSkills();
}

// Remove soft skill
function removeSoftSkill(skill) {
    softSkills = softSkills.filter(s => s !== skill);
    renderSoftSkills();
}

// Render skills tags
function renderSkills() {
    const container = document.getElementById('skillsList');
    container.innerHTML = '';
    skills.forEach(skill => {
        const tag = document.createElement('span');
        tag.className = 'tag';
        tag.textContent = skill;
        const btn = document.createElement('button');
        btn.type = 'button';
        btn.className = 'tag-remove';
        btn.innerHTML = '<i class="fas fa-times"></i>';
        btn.addEventListener('click', () => removeSkill(skill));
        tag.appendChild(btn);
        container.appendChild(tag);
    });
}

// Render soft skills tags
function renderSoftSkills() {
    const container = document.getElementById('softSkillsList');
    container.innerHTML = '';
    softSkills.forEach(skill => {
        const tag = document.createElement('span');
        tag.className = 'tag';
        tag.textContent = skill;
        const btn = document.createElement('button');
        btn.type = 'button';
        btn.className = 'tag-remove';
        btn.innerHTML = '<i class="fas fa-times"></i>';
        btn.addEventListener('click', () => removeSoftSkill(skill));
        tag.appendChild(btn);
        container.appendChild(tag);
    });
}

// Photo & Resume handlers (unchanged)
function handlePhotoPreview(e) {
    const file = e.target.files[0];
    if (file) {
        if (file.size > 2 * 1024 * 1024) { alert('File size must be less than 2MB'); e.target.value=''; return; }
        if (!file.type.startsWith('image/')) { alert('Please select an image file'); e.target.value=''; return; }
        const reader = new FileReader();
        reader.onload = function(e) {
            document.getElementById('photoPreview').src = e.target.result;
            document.getElementById('photoPreview').style.display = 'block';
            document.getElementById('photoPlaceholder').style.display = 'none';
        };
        reader.readAsDataURL(file);
    }
}

function handleResumeUpload(e) {
    const file = e.target.files[0];
    if (file) {
        if (file.size > 5 * 1024 * 1024) { alert('File size must be less than 5MB'); e.target.value=''; return; }
        const allowedTypes = ['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'];
        if (!allowedTypes.includes(file.type)) { alert('Please select a PDF or DOC file'); e.target.value=''; return; }
        document.getElementById('resumeFileName').textContent = file.name;
        document.getElementById('resumeFileSize').textContent = `(${(file.size/1024/1024).toFixed(2)} MB)`;
    }
}

// Character counter
function updateCharCount() {
    const objective = document.getElementById('objective');
    const charCount = document.getElementById('charCount');
    const length = objective.value.length;
    charCount.textContent = `${length}/300 characters`;
    if (length > 300) {
        objective.value = objective.value.substring(0, 300);
        charCount.textContent = '300/300 characters (max reached)';
        charCount.style.color = '#dc3545';
    } else if (length > 250) {
        charCount.style.color = '#ffc107';
    } else {
        charCount.style.color = '#999';
    }
}

// Expose functions globally
window.addSkill = addSkill;
window.addSoftSkill = addSoftSkill;
window.removeSkill = removeSkill;
window.removeSoftSkill = removeSoftSkill;
window.resetForm = function() { /* unchanged */ };
window.saveAsDraft = saveAsDraft;
window.showDeleteModal = function(id) { deleteProfileId = id; document.getElementById('deleteModal').style.display='flex'; };
window.closeDeleteModal = function() { deleteProfileId=null; document.getElementById('deleteModal').style.display='none'; };
window.confirmDelete = function() { showNotification('Delete functionality not implemented', 'error'); closeDeleteModal(); };