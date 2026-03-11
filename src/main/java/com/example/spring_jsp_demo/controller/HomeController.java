package com.example.spring_jsp_demo.controller;

import org.springframework.beans.factory.annotation.Value;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@RestController
public class HomeController {
    
    @Value("${server.port:9090}")
    private String port;
    
    @GetMapping("/")
    public String home(Model model) {
        model.addAttribute("message", "Hello from Spring Boot!");
        model.addAttribute("currentTime", LocalDateTime.now()
            .format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        model.addAttribute("port", port);
        return "index";
    }
    
    @GetMapping("/health")
    @ResponseBody
    public String health() {
        return "OK - Application is healthy!";
    }
    
    @GetMapping("/test")
    @ResponseBody
    public String test() {
        return "Test endpoint working on port " + port;
    }
}