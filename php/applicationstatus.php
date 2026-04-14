<?php
session_start();
require_once 'db_connect.php';

$session_user = $_SESSION['user_id'] ?? null;

$url_user = $_GET['user_id'] ?? null;
$url_session = $_GET['session_id'] ?? null;

$user_id = $session_user ?? $url_user;

if (!$user_id) {
    die("User ID missing");
}

$user_id = (int)$user_id;

if (!$user_id) {
    header("Location: http://localhost:8081/oipwt/login.jsp");
    exit();
}

$current_session = session_id();


$page_title = "My Applications";


$sql = "SELECT id, internship_id, company_name, internship_title, applied_date, status, payment_status 
        FROM applications 
        WHERE user_id=? 
        ORDER BY applied_date DESC";

$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $user_id);
$stmt->execute();
$result = $stmt->get_result();


if (isset($_GET['cancel_id'])) {

    $cancel_id = (int) $_GET['cancel_id'];

    $update_sql = "UPDATE applications SET status='Cancelled' WHERE id=? AND user_id=?";
    $stmt_cancel = $conn->prepare($update_sql);
    $stmt_cancel->bind_param("ii", $cancel_id, $user_id);

    if ($stmt_cancel->execute()) {
        header("Location: applicationstatus.php?user_id=".$user_id);
        exit();
    }
}

?>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><?php echo $page_title; ?></title>

<link rel="stylesheet" href="css/all.min.css">

<style>
:root {
    --primary:#2DA9FF;
    --dark:#0B1C2D;
    --shadow:0 10px 30px rgba(0,0,0,0.1);
}

body {
    margin:0;
    font-family:sans-serif;
    background: url('img/44.jpg') no-repeat center center fixed;
}

/* Header */
.header {
    background:linear-gradient(135deg,var(--dark),var(--primary));
    color:white;
    padding:15px;
    text-align:center;
    position:relative;
}

/* Container */
.container {
    width:90%;
    max-width:900px;
    margin:30px auto;
}

/* Card */
.card {
    background:rgba(255,255,255,0.95);
    padding:20px;
    border-radius:15px;
    box-shadow:var(--shadow);
    cursor: pointer;
    margin-bottom:20px;
    backdrop-filter: blur(5px);
}
/* Status Colors */
.status {
    padding:8px 18px;
    border-radius:25px;
    font-size:13px;
    font-weight:bold;
    display:inline-block;
    color:white;
    min-width:90px;
    text-align:center;
}
.pending {
    background:linear-gradient(135deg,#f6c23e,#f4b400);
}

.accepted {
    background:linear-gradient(135deg,#1cc88a,#17a673);
}

.rejected {
    background:linear-gradient(135deg,#e74a3b,#c0392b);
}
.cancelled {
    background: linear-gradient(135deg,#6c757d,#495057);
}
.back-btn {
    position:absolute;
    left:20px;
    top:20px;
    background:#fff;
    color:#0B1C2D;
    padding:10px 18px;
    border-radius:30px;
    border:none;
    font-weight:600;
    cursor:pointer;
    display:flex;
    align-items:center;
    gap:8px;
    box-shadow:0 4px 10px rgba(0,0,0,0.15);
    transition:0.3s;
}

.back-btn:hover {
    transform:scale(1.05);
}
.btn {
    padding:8px 15px;
    background:linear-gradient(135deg,var(--dark),var(--primary));
    color:#fff;
    border:none;
    border-radius:6px;
    cursor:pointer;
    font-size:12px;
    margin-top:5px;
}

/* Row */
.row {
    display:flex;
    justify-content:space-between;
    align-items:center;
    flex-wrap:wrap;
}

.small {
    font-size:13px;
    color:#555;
}
.proceed-text {
    color: #2DA9FF;
    font-size: 13px;
    font-weight: 600;
    cursor: pointer;
    transition: 0.3s;
}

.proceed-text::after {
    content: " →";
    transition: 0.3s;
}

.proceed-text:hover {
    letter-spacing: 0.5px;
}
</style>
</head>

<body>

<div class="header">
    <h2><i class="fas fa-briefcase"></i> My Applications</h2>

    <!-- Back Button -->
    <br>
    <button class="back-btn" onclick="goBack()">
    <i class="fas fa-arrow-left"></i> Back to Dashboard
</button>
</div>

<div class="container">

<?php if ($result->num_rows > 0): ?>
    
    <?php while($row = $result->fetch_assoc()): 
        $status = strtolower($row['status']);
        $statusClass = "pending";
        if ($status == "accepted") $statusClass = "accepted";
        elseif ($status == "rejected") $statusClass = "rejected";
        elseif($status == "cancelled") $statusClass = "cancelled";
    ?>

    <div class="card">     
           <div class="row">
            <div>
                <h3><?php echo $row['internship_title']; ?></h3>
                <p class="small"><i class="fas fa-building"></i> <?php echo $row['company_name']; ?></p>
                <p class="small"><i class="fas fa-calendar"></i> Applied on: <?php echo date("d M Y", strtotime($row['applied_date'])); ?></p>
                <p class="small"><i class="fas fa-credit-card"></i> Payment: <?php echo $row['payment_status']; ?></p>
            </div>

            <div style="text-align:right;">
                <span class="status <?php echo $statusClass; ?>">
                    <?php echo $row['status']; ?>
                </span>
                <br>
                </br>
                <?php if ($status == "accepted" && ($row['payment_status'] == "PENDING" || $row['payment_status'] == null)): ?>
                    <span class="proceed-text" onclick="goToPayment(
                        '<?php echo addslashes($row['internship_title']); ?>',
                        '<?php echo addslashes($row['company_name']); ?>',
                        '3 Months',
                        'Immediate',
                        '5000',
                        '<?php echo $row['id']; ?>',                
                        '<?php echo $row['internship_id']; ?>'      
                    )"
                    >
                        Proceed Further
    </span>
<?php endif; ?>

            </div>
            
        </div>
          <?php if ($status != "cancelled" && $row['payment_status'] != "SUCCESS"): ?>
    <button class="btn cancel-btn" onclick="cancelApp(<?php echo $row['id']; ?>)">
        Cancel
    </button>
<?php endif; ?>
    </div>

    <?php endwhile; ?>

<?php else: ?>

    <div class="card">
        <p style="text-align:center;">No applications found.</p>
    </div>

<?php endif; ?>

</div>

<script>
function showStatus(status){
    alert("Application Status: " + status);
}

function goBack(){
    window.location.href = "http://localhost:8081/oipwtt/studenthome.jsp";
}
function cancelApp(id){
    if(confirm("Cancel this application?")){
        window.location.href =
        "applicationstatus.php?user_id=<?php echo $user_id; ?>&cancel_id=" + id;
    }
}
function goToPayment(internshipName, companyName, duration, startDate, amount, applicationId, internshipId) {

    const url = "http://localhost:8081/oipwtt/payment.html?" +
        "internship_name=" + encodeURIComponent(internshipName) +
        "&company_name=" + encodeURIComponent(companyName) +
        "&duration=" + encodeURIComponent(duration) +
        "&start_date=" + encodeURIComponent(startDate) +
        "&amount=" + encodeURIComponent(amount) +
        "&application_id=" + encodeURIComponent(applicationId) +
        "&internship_id=" + encodeURIComponent(internshipId);  

    window.location.href = url;
}
</script>

</body>
</html>