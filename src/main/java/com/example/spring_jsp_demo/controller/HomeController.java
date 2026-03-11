package com.example.spring_jsp_demo.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.List;

@Controller
public class HomeController {

    @GetMapping("/")
    public String home(Model model) {
        // Add simple data
        model.addAttribute("message", "Hello from Spring Boot with JSP in templates folder!");
        model.addAttribute("currentTime", LocalDateTime.now()
            .format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        
        // Add a list of items
        List<String> frameworks = Arrays.asList("Spring Boot", "JSP", "Maven", "Eclipse");
        model.addAttribute("frameworks", frameworks);
        
        return "index";
    }
    
    @GetMapping("/about")
    public String about(Model model) {
        model.addAttribute("title", "About This Demo");
        model.addAttribute("description", "This is a simple Spring Boot application with JSP pages stored in the templates folder.");
        return "about";
    }
}