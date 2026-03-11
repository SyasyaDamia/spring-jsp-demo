<!DOCTYPE html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<html>
<head>
    <meta charset="UTF-8">
    <title>About - JSP in Templates</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #ff6b6b 0%, #ff8e53 100%);
            min-height: 100vh;
            padding: 20px;
        }
        .container {
            max-width: 800px;
            margin: 50px auto;
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        }
        h1 {
            color: #333;
            border-bottom: 3px solid #ff6b6b;
            padding-bottom: 10px;
            margin-bottom: 20px;
        }
        .nav {
            background: #f1f1f1;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .nav a {
            margin-right: 15px;
            text-decoration: none;
            color: #ff6b6b;
            font-weight: bold;
        }
        .info-box {
            background: #fff3f0;
            border-radius: 5px;
            padding: 20px;
            margin: 20px 0;
        }
        .location {
            background: #333;
            color: white;
            padding: 10px;
            border-radius: 5px;
            font-family: monospace;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="nav">
            <a href="/">Home</a>
            <a href="/about">About</a>
        </div>
        
        <h1>📖 ${title}</h1>
        
        <div class="info-box">
            <p style="font-size: 1.2em;">${description}</p>
        </div>
        
        <h3>Configuration Details:</h3>
        <ul style="margin: 15px 0 15px 30px;">
            <li>JSP files location: <strong>src/main/resources/templates/</strong></li>
            <li>View prefix configured as: <strong>/templates/</strong></li>
            <li>View suffix: <strong>.jsp</strong></li>
            <li>Controller returns view name without extension</li>
        </ul>
        
        <div class="location">
            🔧 This file is located at: src/main/resources/templates/about.jsp
        </div>
        
        <div style="margin-top: 20px;">
            <p><a href="/" style="color: #ff6b6b;">← Back to Home</a></p>
        </div>
    </div>
</body>
</html>