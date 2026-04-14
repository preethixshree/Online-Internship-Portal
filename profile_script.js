// ===== COMPANY PROFILE VALIDATION =====

document.getElementById("companyProfileForm").addEventListener("submit", function(e) {

    let isValid = true;

    const companyName = document.getElementById("companyName");
    const industry = document.getElementById("industry");
    const email = document.getElementById("email");
    const phone = document.getElementById("phone");
    const address = document.getElementById("address");

    // Reset previous errors
    document.querySelectorAll("input, select").forEach(el => {
        el.classList.remove("input-error");
    });

    // ===== Company Name =====
    if (companyName.value.trim().length < 3) {
        showError(companyName, "Company name must be at least 3 characters");
        isValid = false;
    }

    // ===== Industry =====
    if (industry.value === "") {
        showError(industry, "Please select industry");
        isValid = false;
    }

    // ===== Email =====
    if (!isValidEmail(email.value)) {
        showError(email, "Enter valid email");
        isValid = false;
    }

    // ===== Phone (optional but validated if entered) =====
    if (phone.value.trim() !== "") {
        const phoneRegex = /^[0-9+\-\s()]{7,15}$/;
        if (!phoneRegex.test(phone.value)) {
            showError(phone, "Invalid phone number");
            isValid = false;
        }
    }

    // ===== Address =====
    if (address.value.trim().length < 5) {
        showError(address, "Address too short");
        isValid = false;
    }

    // ===== Stop form if invalid =====
    if (!isValid) {
        e.preventDefault();
    }
});


// ===== EMAIL VALIDATION =====
function isValidEmail(email) {
    const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return regex.test(email);
}


// ===== SHOW ERROR =====
function showError(input, message) {
    input.classList.add("input-error");

    // Remove old message if exists
    let old = input.parentElement.querySelector(".error-msg");
    if (old) old.remove();

    const error = document.createElement("div");
    error.className = "error-msg";
    error.style.color = "red";
    error.style.fontSize = "12px";
    error.style.marginTop = "5px";
    error.innerText = message;

    input.parentElement.appendChild(error);
}


// ===== LIVE VALIDATION =====
document.querySelectorAll("input, select").forEach(field => {
    field.addEventListener("input", function() {
        this.classList.remove("input-error");

        let msg = this.parentElement.querySelector(".error-msg");
        if (msg) msg.remove();
    });
});


// ===== IMAGE PREVIEW =====
document.getElementById("logo").addEventListener("change", function() {
    const file = this.files[0];

    if (!file) return;

    // Validate type
    if (!file.type.startsWith("image/")) {
        alert("Please upload a valid image");
        this.value = "";
        return;
    }

    // Validate size (max 5MB)
    if (file.size > 5 * 1024 * 1024) {
        alert("Image must be less than 5MB");
        this.value = "";
        return;
    }

    const reader = new FileReader();
    reader.onload = function(e) {
        document.getElementById("logoPreview").src = e.target.result;
        const img = document.getElementById("logoPreview");
        img.src = e.target.result;
        img.style.display = "block";
        img.style.width = "100%";
        img.style.height = "100%";
        img.style.objectFit = "contain";
        document.getElementById("logoPlaceholder").style.display = "none";
    };
    reader.readAsDataURL(file);
});