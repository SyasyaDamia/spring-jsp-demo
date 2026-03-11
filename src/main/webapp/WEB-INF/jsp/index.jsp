<!DOCTYPE html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html>
<head>
    <meta charset="UTF-8">
    <title>Spring Boot JSP in Templates</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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
            border-bottom: 3px solid #667eea;
            padding-bottom: 10px;
            margin-bottom: 20px;
        }
        .info-box {
            background: #f8f9fa;
            border-left: 4px solid #667eea;
            padding: 15px;
            margin: 20px 0;
            border-radius: 0 5px 5px 0;
        }
        .time {
            color: #764ba2;
            font-weight: bold;
            font-size: 1.2em;
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
            color: #667eea;
            font-weight: bold;
        }
        .nav a:hover {
            color: #764ba2;
        }
        ul {
            list-style-type: none;
        }
        li {
            padding: 8px;
            margin: 5px 0;
            background: #f1f1f1;
            border-radius: 3px;
        }
        .location-badge {
            background: #ffd700;
            color: #333;
            padding: 5px 10px;
            border-radius: 15px;
            font-size: 0.9em;
            display: inline-block;
            margin-bottom: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        
        <div class="nav">
            <a href="/">Home</a>
        </div>
        
        <h1>🌸 Spring Boot with JSP in Templates Folder</h1>
        
        <div class="info-box">
            <p><strong>Message:</strong> ${message}</p>
            <p class="time">⏰ Current Time: ${currentTime}</p>
        </div>
        
        <h3>Technologies used in this demo:</h3>
        <ul>
            <c:forEach var="framework" items="${frameworks}">
                <li>✨ ${framework}</li>
            </c:forEach>
        </ul>
        
        <div style="margin-top: 20px; padding: 15px; background: #e8f4fd; border-radius: 5px;">
            <h4>📝 Note:</h4>
            <p>This JSP is being served from the <strong>---</strong> </p>
        </div>
    </div>
</body>
</html>