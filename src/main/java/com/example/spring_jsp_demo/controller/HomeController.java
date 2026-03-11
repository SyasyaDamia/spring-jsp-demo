package com.example.spring_jsp_demo.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Controller  // Changed from @RestController to @Controller
public class HomeController {
    
    @Value("${server.port:9090}")
    private String port;
    
    @GetMapping("/")  // Added the slash
    public String home(Model model) {
        model.addAttribute("message", "Hello from Spring Boot!");
        model.addAttribute("currentTime", LocalDateTime.now()
            .format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        model.addAttribute("port", port);
        return "index";  // This now works - returns view name
    }
    
    @GetMapping("/health")
    @ResponseBody  // Keep @ResponseBody for this endpoint
    public String health() {
        return "OK - Application is healthy!";
    }
    
    @GetMapping("/test")
    @ResponseBody  // Keep @ResponseBody for this endpoint
    public String test() {
        return "Test endpoint working on port " + port;
    }
}