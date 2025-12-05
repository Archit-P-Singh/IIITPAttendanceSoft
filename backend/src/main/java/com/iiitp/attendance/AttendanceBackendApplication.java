package com.iiitp.attendance;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import com.iiitp.attendance.model.Student;
import com.iiitp.attendance.repository.StudentRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;

@SpringBootApplication
public class AttendanceBackendApplication {

	public static void main(String[] args) {
		SpringApplication.run(AttendanceBackendApplication.class, args);
	}

	@Bean
	CommandLineRunner initDatabase(StudentRepository repository) {
		return args -> {
			if (repository.findByRollNo("112315025").isEmpty()) {
				Student student = new Student();
				student.setName("Amar Singh");
				student.setRollNo("112315025");
				student.setQrCode("QR_112315025");
				student.setDepartment("CSE");
				repository.save(student);
				System.out.println("Added dummy student: Amar Singh (112315025)");
			}
		};
	}

}
