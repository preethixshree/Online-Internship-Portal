<%@ page contentType="application/json;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.intern.dbconnection" %>

<%
boolean success = false;
String message = "";

Connection conn = null;
PreparedStatement pstmtCheck = null;
PreparedStatement pstmtStudent = null;
PreparedStatement pstmtInsert = null;
PreparedStatement pstmtUpdate = null;
ResultSet rsCheck = null;
ResultSet rsStudent = null;

try {

    // SESSION
    Integer userIdObj = (Integer) session.getAttribute("user_id");
    String email = (String) session.getAttribute("email");

    if (userIdObj == null || email == null) {
        out.print("{\"success\": false, \"message\": \"User not logged in\"}");
        return;
    }

    int userId = userIdObj;

    // REQUEST DATA
    int internshipId = Integer.parseInt(request.getParameter("internship_id"));
    String companyName = request.getParameter("company_name");
    String internshipTitle = request.getParameter("internship_title");

    String transactionId = request.getParameter("transaction_id");
    String amountStr = request.getParameter("amount");

    double amount = 0.0;
    if (amountStr != null && !amountStr.isEmpty()) {
        amount = Double.parseDouble(amountStr);
    }

    // PAYMENT STATUS
    String paymentStatus = (transactionId != null && !transactionId.isEmpty())
            ? "SUCCESS"
            : "PENDING";

    conn = dbconnection.getConnection();
    conn.setAutoCommit(false);

    // 1. CHECK DUPLICATE
    String checkSql = "SELECT id FROM applications WHERE user_id=? AND internship_id=?";
    pstmtCheck = conn.prepareStatement(checkSql);
    pstmtCheck.setInt(1, userId);
    pstmtCheck.setInt(2, internshipId);
    rsCheck = pstmtCheck.executeQuery();

    if (rsCheck.next()) {

        // ✅ RECORD EXISTS → UPDATE PAYMENT
        if (transactionId != null && !transactionId.isEmpty()) {

            String updateSql = "UPDATE applications SET payment_status=?, payment_amount=?, payment_transaction_id=? WHERE user_id=? AND internship_id=?";
            pstmtUpdate = conn.prepareStatement(updateSql);

            pstmtUpdate.setString(1, "SUCCESS");
            pstmtUpdate.setDouble(2, amount);
            pstmtUpdate.setString(3, transactionId);
            pstmtUpdate.setInt(4, userId);
            pstmtUpdate.setInt(5, internshipId);

            int updated = pstmtUpdate.executeUpdate();

            if (updated > 0) {
                conn.commit();
                success = true;
                message = "Payment updated successfully!";
            } else {
                conn.rollback();
                message = "Payment update failed";
            }

        } else {
            message = "Already applied!";
        }

    } else {

        // 2. FETCH STUDENT PROFILE
        String studentSql = "SELECT * FROM student_profiles WHERE user_id=?";
        pstmtStudent = conn.prepareStatement(studentSql);
        pstmtStudent.setInt(1, userId);
        rsStudent = pstmtStudent.executeQuery();

        if (rsStudent.next()) {

            String coverLetter = rsStudent.getString("objective");
            if (coverLetter == null) coverLetter = "";

            // 3. INSERT APPLICATION
            String insertSql =
                    "INSERT INTO applications (" +
                    "user_id, internship_id, company_name, internship_title, " +
                    "full_name, email, phone, education, branch, semester, " +
                    "skills, experience, resume_path, cover_letter, " +
                    "payment_status, payment_amount, payment_transaction_id" +
                    ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

            pstmtInsert = conn.prepareStatement(insertSql);

            pstmtInsert.setInt(1, userId);
            pstmtInsert.setInt(2, internshipId);
            pstmtInsert.setString(3, companyName);
            pstmtInsert.setString(4, internshipTitle);

            pstmtInsert.setString(5, rsStudent.getString("full_name"));
            pstmtInsert.setString(6, rsStudent.getString("email"));
            pstmtInsert.setString(7, rsStudent.getString("phone"));

            pstmtInsert.setString(8, rsStudent.getString("degree"));
            pstmtInsert.setString(9, rsStudent.getString("major"));
            pstmtInsert.setString(10, rsStudent.getString("graduation_year"));

            pstmtInsert.setString(11, rsStudent.getString("technical_skills"));
            pstmtInsert.setString(12, rsStudent.getString("soft_skills"));
            pstmtInsert.setString(13, rsStudent.getString("resume_path"));

            pstmtInsert.setString(14, coverLetter);

            pstmtInsert.setString(15, paymentStatus);
            pstmtInsert.setDouble(16, amount);
            pstmtInsert.setString(17, transactionId);

            int rows = pstmtInsert.executeUpdate();

            if (rows > 0) {
                conn.commit();
                success = true;
                message = "Application submitted successfully!";
            } else {
                conn.rollback();
                message = "Failed to apply";
            }

        } else {
            message = "Please create your student profile first!";
        }
    }

} catch (Exception e) {
    e.printStackTrace();
    message = "Error: " + e.getMessage();
    if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
} finally {
    if (rsCheck != null) try { rsCheck.close(); } catch (SQLException e) {}
    if (rsStudent != null) try { rsStudent.close(); } catch (SQLException e) {}
    if (pstmtCheck != null) try { pstmtCheck.close(); } catch (SQLException e) {}
    if (pstmtStudent != null) try { pstmtStudent.close(); } catch (SQLException e) {}
    if (pstmtInsert != null) try { pstmtInsert.close(); } catch (SQLException e) {}
    if (pstmtUpdate != null) try { pstmtUpdate.close(); } catch (SQLException e) {}
    if (conn != null) try { conn.close(); } catch (SQLException e) {}
}

// ✅ FINAL JSON RESPONSE (OUTSIDE TRY)
message = message.replace("\"", "'");
response.setContentType("application/json");
out.print("{\"success\": " + success + ", \"message\": \"" + message + "\"}");
%>