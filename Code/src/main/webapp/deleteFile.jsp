<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>File Deletion | VeriDedup</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <style>
        body { 
            background-color: #f4f6f9; 
            display: flex; 
            justify-content: center; 
            align-items: center; 
            height: 100vh; 
        }
        .alert-box { 
            max-width: 600px; 
            text-align: center; 
            border-radius: 12px; 
            padding: 20px;
        }
    </style>
</head>
<body>

<div class="alert alert-danger alert-box">
    <h4>❌ Deletion Not Allowed!</h4>
    <p>Deletion is not possible by Cloud Provider due to Integrity Issues.</p>
    <a href="javascript:history.back()" class="btn btn-primary">⬅ Go Back</a>
</div>

</body>
</html>
