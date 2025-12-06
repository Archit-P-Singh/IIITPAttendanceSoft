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
			if (repository.findByRollNo("admin").isEmpty()) {
				Student admin = new Student();
				admin.setName("Administrator");
				admin.setRollNo("admin");
				admin.setQrCode("ADMIN_QR");
				admin.setDepartment("ADMIN");
				admin.setPassword("admin123");
				admin.setRole(com.iiitp.attendance.model.Role.ADMIN);
				repository.save(admin);
				System.out.println("Added Admin: admin / admin123");
			}

			if (repository.findByRollNo("manager").isEmpty()) {
				Student manager = new Student();
				manager.setName("Mess Manager");
				manager.setRollNo("manager");
				manager.setQrCode("MANAGER_QR");
				manager.setDepartment("MESS");
				manager.setPassword("manager123");
				manager.setRole(com.iiitp.attendance.model.Role.MESS_MANAGER);
				repository.save(manager);
				System.out.println("Added Manager: manager / manager123");
			}

			if (repository.findByRollNo("112315025").isEmpty()) {
				Student student = new Student();
				student.setName("Amar Singh");
				student.setRollNo("112315025");
				student.setQrCode("QR_112315025");
				student.setDepartment("CSE");
				student.setPassword("password");
				student.setRole(com.iiitp.attendance.model.Role.STUDENT);
				student.setEmail("test@example.com");
				repository.save(student);
				System.out.println("Added Student: Amar Singh (112315025) / password / test@example.com");
			}
		};
	}

}
