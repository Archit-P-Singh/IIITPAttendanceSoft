# IIITPAttendanceSoft

**IIITPAttendanceSoft** is a comprehensive solution designed to digitize and streamline mess attendance and rebate calculations for IIIT Pune. By leveraging QR code technology, the system ensures accurate, real-time tracking of student meals, reducing manual errors and administrative overhead.

## 🚀 Features

### Core Functionality
*   **QR Code-Based Attendance**: Students scan a dynamically generated QR code to mark their attendance for meals.
*   **Real-time Synchronization**: Attendance data is instantly updated in the central database.
*   **Rebate Management**: Automates the calculation of rebates for missed meals based on institute policies.

### User Roles
*   **Student**: View personal attendance history, check rebate status, and generate daily QR codes.
*   **Mess Manager**: Scan student QR codes, view daily headcount, and manage meal sessions.
*   **Admin**: oversee the entire system, manage users (students, managers), and access detailed reports.

### Analytics & Reporting
*   **Dashboard**: Visual analytics using charts to display attendance trends and meal consumption.
*   **Reports**: Exportable data for administrative audits.

## 🛠️ Technology Stack

### Backend
*   **Framework**: [Spring Boot](https://spring.io/projects/spring-boot) (Java 22)
*   **Database**: MySQL 8.0
*   **ORM**: Hibernate / Spring Data JPA
*   **Authentication**: Custom implementation / Spring Security (implied)
*   **Email Service**: JavaMailSender (Gmail SMTP)

### Frontend
*   **Framework**: [Flutter](https://flutter.dev/) (Dart 3.7.2)
*   **State Management**: Provider
*   **QR Scanning**: `mobile_scanner`
*   **QR Generation**: `qr_flutter`
*   **Charts**: `fl_chart`

## 📋 Prerequisites

Ensure you have the following installed before setting up the project:

*   **Java Development Kit (JDK)**: Version 22 or higher.
*   **Flutter SDK**: Version 3.22.0 or higher (Dart 3.4.0+).
*   **MySQL Server**: Version 8.0 or higher.
*   **Maven**: For backend dependency management.
*   **Git**: For version control.

## ⚙️ Installation & Setup

### 1. Database Setup
1.  Install and start MySQL Server.
2.  Create a database named `attendance`.
3.  The tables will be automatically created by Hibernate on the first run, or you can manually execute the script located at `database/schema.sql`.

```sql
CREATE DATABASE attendance;
```

### 2. Backend Setup
1.  Navigate to the backend directory:
    ```bash
    cd backend
    ```
2.  Update the `src/main/resources/application.properties` file with your MySQL credentials and Mail configuration:
    ```properties
    spring.datasource.url=jdbc:mysql://localhost:3306/attendance?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
    spring.datasource.username=YOUR_MYSQL_USERNAME
    spring.datasource.password=YOUR_MYSQL_PASSWORD
    
    # Mail Configuration
    spring.mail.username=YOUR_EMAIL@gmail.com
    spring.mail.password=YOUR_APP_PASSWORD
    ```
3.  Build and run the application:
    ```bash
    ./mvnw spring-boot:run
    ```
    The backend server will start at `http://localhost:8080`.

### 3. Frontend Setup
1.  Navigate to the frontend directory:
    ```bash
    cd frontend
    ```
2.  Install dependencies:
    ```bash
    flutter pub get
    ```
3.  Run the application (ensure a device/emulator is connected):
    ```bash
    flutter run
    ```

## 📱 Usage Guide

1.  **Registration**:
    *   Students register with their Roll Number and details.
    *   Admins/Managers credentials are pre-configured or created via database (as per current logic).
2.  **Marking Attendance**:
    *   **Student** opens the app -> Generates QR Code.
    *   **Mess Manager** opens the app -> Scans the Student's QR Code.
    *   Attendance is marked as "Present".

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
