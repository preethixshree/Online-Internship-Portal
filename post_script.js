// post_script.js - Complete JavaScript for Internship Posting Form

// Wait for DOM to be fully loaded
document.addEventListener('DOMContentLoaded', function() {
    
    // Get form elements
    const internshipForm = document.getElementById('internshipForm');
    const stipendType = document.getElementById('stipendType');
    const amountGroup = document.getElementById('amountGroup');
    const amount = document.getElementById('amount');
    const deadline = document.getElementById('deadline');
    
    // ===== STIPEND TOGGLE FUNCTIONALITY =====
    // Toggle amount field based on stipend type
    if (stipendType) {
        stipendType.addEventListener('change', function() {
            if (this.value === 'Paid' || this.value === 'Stipend') {
                amountGroup.style.display = 'block';
                amount.required = true;
            } else {
                amountGroup.style.display = 'none';
                amount.required = false;
                amount.value = ''; // Clear amount when hidden
            }
        });
    }
    
    // ===== DEADLINE DATE VALIDATION =====
    // Set minimum date for deadline (today)
    if (deadline) {
        const today = new Date().toISOString().split('T')[0];
        deadline.min = today;
        
        // Also prevent past dates from being selected
        deadline.addEventListener('change', function() {
            const selectedDate = new Date(this.value);
            const todayDate = new Date(today);
            if (selectedDate < todayDate) {
                alert('Deadline cannot be in the past');
                this.value = today;
            }
        });
    }
    
    // ===== FORM SUBMISSION & VALIDATION =====
    if (internshipForm) {
        internshipForm.addEventListener('submit', function(e) {
            
            // Validate all required fields
            const requiredFields = this.querySelectorAll('[required]');
            let isValid = true;
            let firstInvalidField = null;
            
            // Reset all field borders first
            requiredFields.forEach(field => {
                field.style.borderColor = '#ddd';
            });
            
            // Check each required field
            requiredFields.forEach(field => {
                if (!field.value.trim()) {
                    isValid = false;
                    field.style.borderColor = '#dc3545';
                    
                    // Store the first invalid field for focus
                    if (!firstInvalidField) {
                        firstInvalidField = field;
                    }
                }
            });
            
            // Special validation for amount field based on stipend type
            const stipendTypeValue = stipendType ? stipendType.value : '';
            const amountValue = amount ? amount.value : '';
            
            if ((stipendTypeValue === 'Paid' || stipendTypeValue === 'Stipend') && 
                (!amountValue || parseFloat(amountValue) <= 0)) {
                
                isValid = false;
                if (amount) {
                    amount.style.borderColor = '#dc3545';
                    if (!firstInvalidField) {
                        firstInvalidField = amount;
                    }
                }
                alert('Please enter a valid amount (greater than 0) for paid/stipend internships');
                e.preventDefault();
                return false;
            }
            
            // Validate deadline is not empty
            if (deadline && !deadline.value) {
                isValid = false;
                deadline.style.borderColor = '#dc3545';
                if (!firstInvalidField) {
                    firstInvalidField = deadline;
                }
            }
            
            // If validation fails, show alert and focus first invalid field
            if (!isValid) {
                alert('Please fill in all required fields correctly');
                e.preventDefault();
                
                // Focus on the first invalid field
                if (firstInvalidField) {
                    firstInvalidField.focus();
                }
                return false;
            }
            
            // If validation passes, show loading state
            const submitBtn = this.querySelector('.btn-submit');
            if (submitBtn) {
                const originalText = submitBtn.innerHTML;
                submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Posting...';
                submitBtn.disabled = true;
                
                // Allow the form to submit normally to the servlet
                // The form will submit and redirect to companyhome.jsp
                
                // Note: We don't call e.preventDefault() here, so form submits normally
                // The loading state will be shown briefly before page redirect
                
                // Optional: Store a flag to prevent double submission
                this.dataset.submitting = 'true';
            }
            
            return true; // Allow form submission
        });
    }
    
    // ===== ADDITIONAL HELPER FUNCTIONS =====
    
    // Character counter for description (optional)
    const description = document.getElementById('description');
    if (description) {
        const counter = document.createElement('small');
        counter.className = 'char-counter';
        counter.style.cssText = 'display: block; text-align: right; color: #666; margin-top: 5px;';
        description.parentNode.appendChild(counter);
        
        description.addEventListener('input', function() {
            const remaining = 2000 - this.value.length;
            counter.textContent = `${this.value.length}/2000 characters`;
            counter.style.color = remaining < 100 ? '#dc3545' : '#666';
        });
    }
    
    // Skills input enhancement (optional)
    const skills = document.getElementById('skills');
    if (skills) {
        skills.addEventListener('blur', function() {
            // Split skills by comma and trim
            const skillArray = this.value.split(',').map(skill => skill.trim());
            this.value = skillArray.join(', ');
        });
    }
    
    // ===== INPUT RESTORATION AFTER PAGE RELOAD =====
    // If there was a server-side validation error, restore the amount field visibility
    if (stipendType && amountGroup) {
        const savedStipendType = stipendType.value;
        if (savedStipendType === 'Paid' || savedStipendType === 'Stipend') {
            amountGroup.style.display = 'block';
            if (amount) amount.required = true;
        }
    }
    
    // ===== PREVENT DOUBLE SUBMISSION =====
    // Disable submit button on form submit to prevent double posting
    window.addEventListener('beforeunload', function() {
        const submitBtn = internshipForm?.querySelector('.btn-submit');
        if (submitBtn) {
            submitBtn.disabled = true;
        }
    });
});

// ===== HELPER FUNCTION FOR FORMATTING CURRENCY (optional) =====
function formatCurrency(amount) {
    return new Intl.NumberFormat('en-IN', {
        style: 'currency',
        currency: 'INR',
        minimumFractionDigits: 0,
        maximumFractionDigits: 0
    }).format(amount);
}

// ===== HELPER FUNCTION FOR VALIDATING DATE (optional) =====
function isValidDate(dateString) {
    const date = new Date(dateString);
    return date instanceof Date && !isNaN(date);
}

// ===== EXPORT FUNCTIONS IF NEEDED (for modular JavaScript) =====
// This is optional and only needed if you're using modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        formatCurrency,
        isValidDate
    };
}