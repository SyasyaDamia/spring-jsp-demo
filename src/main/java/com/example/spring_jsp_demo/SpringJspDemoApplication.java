package com.example.spring_jsp_demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class SpringJspDemoApplication {

	public static void main(String[] args) {
        SpringApplication.run(SpringJspDemoApplication.class, args);
        System.out.println("🚀 Application started with simple one!");
        System.out.println("🌐 Access the app at: http://localhost:9090");
    }

}
