-- MySQL dump 10.13  Distrib 8.0.34, for Win64 (x86_64)
--
-- Host: localhost    Database: school_db
-- ------------------------------------------------------
-- Server version	8.0.34

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `announcements`
--

DROP TABLE IF EXISTS `announcements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `announcements` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(100) NOT NULL,
  `description` text NOT NULL,
  `created_by` int NOT NULL,
  `role` enum('admin','teacher') NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_announcement_user` (`created_by`),
  CONSTRAINT `fk_announcement_user` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `announcements`
--

LOCK TABLES `announcements` WRITE;
/*!40000 ALTER TABLE `announcements` DISABLE KEYS */;
INSERT INTO `announcements` VALUES (1,'Circular for Holiday','Tomorrow is declared a holiday due to second Saturday.',3,'teacher','2025-12-30 07:45:29'),(2,'Homework','Complete math activity book pages 30 and 31.',3,'teacher','2025-12-30 07:45:35'),(3,'Exam Notice','Unit test will be conducted on Friday.',6,'teacher','2025-12-30 08:21:33'),(4,'Exam Notice','Unit test will be conducted on Friday.',6,'teacher','2025-12-30 08:28:11');
/*!40000 ALTER TABLE `announcements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attendance`
--

DROP TABLE IF EXISTS `attendance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `attendance` (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` int NOT NULL,
  `date` date NOT NULL,
  `status` enum('present','absent','holiday') NOT NULL,
  `marked_by` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_attendance` (`student_id`,`date`),
  KEY `fk_attendance_teacher` (`marked_by`),
  CONSTRAINT `fk_attendance_student` FOREIGN KEY (`student_id`) REFERENCES `students` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_attendance_teacher` FOREIGN KEY (`marked_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attendance`
--

LOCK TABLES `attendance` WRITE;
/*!40000 ALTER TABLE `attendance` DISABLE KEYS */;
INSERT INTO `attendance` VALUES (1,3,'2025-12-30','present',6,'2025-12-30 08:39:48'),(12,7,'2025-12-01','present',6,'2025-12-31 08:52:08'),(13,7,'2025-12-02','present',6,'2025-12-31 08:52:08'),(14,7,'2025-12-03','present',6,'2025-12-31 08:52:08'),(15,7,'2025-12-04','absent',6,'2025-12-31 08:52:08'),(16,7,'2025-12-05','present',6,'2025-12-31 08:52:08'),(17,7,'2025-12-06','holiday',6,'2025-12-31 08:52:08'),(18,7,'2025-12-07','present',6,'2025-12-31 08:52:08'),(19,7,'2025-12-08','present',6,'2025-12-31 08:52:08'),(20,7,'2025-12-09','absent',6,'2025-12-31 08:52:08'),(21,7,'2025-12-10','present',6,'2025-12-31 08:52:08'),(22,7,'2026-01-05','present',6,'2026-01-02 15:52:07'),(23,3,'2026-01-05','absent',6,'2026-01-02 15:52:07'),(24,7,'2026-01-02','present',6,'2026-01-02 16:03:41'),(25,3,'2026-01-02','holiday',6,'2026-01-02 16:03:41');
/*!40000 ALTER TABLE `attendance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `exams`
--

DROP TABLE IF EXISTS `exams`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `exams` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `class` varchar(20) NOT NULL,
  `exam_date` date NOT NULL,
  `created_by` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_exam_teacher` (`created_by`),
  CONSTRAINT `fk_exam_teacher` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exams`
--

LOCK TABLES `exams` WRITE;
/*!40000 ALTER TABLE `exams` DISABLE KEYS */;
INSERT INTO `exams` VALUES (1,'Mid Term','10','2025-12-20',6,'2025-12-31 05:01:39'),(2,'Mid Term','10','2025-12-19',6,'2025-12-31 09:11:47');
/*!40000 ALTER TABLE `exams` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fee_payments`
--

DROP TABLE IF EXISTS `fee_payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fee_payments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` int NOT NULL,
  `amount_paid` decimal(10,2) NOT NULL,
  `payment_date` date NOT NULL,
  `payment_mode` enum('cash','online','upi','card') NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_payment_student` (`student_id`),
  CONSTRAINT `fk_payment_student` FOREIGN KEY (`student_id`) REFERENCES `students` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fee_payments`
--

LOCK TABLES `fee_payments` WRITE;
/*!40000 ALTER TABLE `fee_payments` DISABLE KEYS */;
INSERT INTO `fee_payments` VALUES (1,3,15000.00,'2025-06-01','online','2025-12-30 10:11:02'),(2,3,10000.00,'2025-09-01','upi','2025-12-30 10:11:02'),(3,3,5000.00,'2025-12-15','cash','2025-12-31 04:04:00'),(4,7,15000.00,'2025-05-31','online','2025-12-31 09:02:46'),(5,7,10000.00,'2025-08-31','upi','2025-12-31 09:02:46'),(6,7,5000.00,'2025-12-14','cash','2025-12-31 09:02:46');
/*!40000 ALTER TABLE `fee_payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fees`
--

DROP TABLE IF EXISTS `fees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fees` (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` int NOT NULL,
  `total_amount` decimal(10,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_fees_student` (`student_id`),
  CONSTRAINT `fk_fees_student` FOREIGN KEY (`student_id`) REFERENCES `students` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fees`
--

LOCK TABLES `fees` WRITE;
/*!40000 ALTER TABLE `fees` DISABLE KEYS */;
INSERT INTO `fees` VALUES (1,3,50000.00,'2025-12-30 10:10:54'),(2,7,50000.00,'2025-12-31 09:02:19');
/*!40000 ALTER TABLE `fees` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `messages`
--

DROP TABLE IF EXISTS `messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `messages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` int NOT NULL,
  `teacher_id` int NOT NULL,
  `sender` enum('student','teacher') NOT NULL,
  `message` text NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_message_student` (`student_id`),
  KEY `fk_message_teacher` (`teacher_id`),
  CONSTRAINT `fk_message_student` FOREIGN KEY (`student_id`) REFERENCES `students` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_message_teacher` FOREIGN KEY (`teacher_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `messages`
--

LOCK TABLES `messages` WRITE;
/*!40000 ALTER TABLE `messages` DISABLE KEYS */;
INSERT INTO `messages` VALUES (1,3,6,'student','Sir, can you explain quadratic equations?','2025-12-31 04:27:14'),(2,3,6,'teacher','Sure, I will explain it in tomorrow\'s class.','2025-12-31 04:30:07'),(3,7,6,'student','Sir, can you explain quadratic equations?','2025-12-31 10:27:47'),(4,7,6,'student','hello sir','2026-01-02 07:12:22'),(5,7,6,'teacher','sure i will explain ','2026-01-02 13:51:02');
/*!40000 ALTER TABLE `messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `results`
--

DROP TABLE IF EXISTS `results`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `results` (
  `id` int NOT NULL AUTO_INCREMENT,
  `exam_id` int NOT NULL,
  `student_id` int NOT NULL,
  `subject` varchar(50) NOT NULL,
  `marks` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_result` (`exam_id`,`student_id`,`subject`),
  KEY `fk_result_student` (`student_id`),
  CONSTRAINT `fk_result_exam` FOREIGN KEY (`exam_id`) REFERENCES `exams` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_result_student` FOREIGN KEY (`student_id`) REFERENCES `students` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `results`
--

LOCK TABLES `results` WRITE;
/*!40000 ALTER TABLE `results` DISABLE KEYS */;
INSERT INTO `results` VALUES (1,1,3,'Maths',85,'2025-12-31 05:02:11'),(2,1,7,'Mathematics',85,'2025-12-31 09:12:25'),(3,1,7,'Science',78,'2025-12-31 09:12:25'),(4,1,7,'English',88,'2025-12-31 09:12:25'),(5,1,7,'Social Studies',74,'2025-12-31 09:12:25');
/*!40000 ALTER TABLE `results` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `students`
--

DROP TABLE IF EXISTS `students`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `students` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `class` varchar(20) DEFAULT NULL,
  `section` varchar(10) DEFAULT NULL,
  `roll_number` varchar(20) DEFAULT NULL,
  `parent_name` varchar(100) DEFAULT NULL,
  `phone` varchar(15) DEFAULT NULL,
  `address` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `students_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `students`
--

LOCK TABLES `students` WRITE;
/*!40000 ALTER TABLE `students` DISABLE KEYS */;
INSERT INTO `students` VALUES (4,3,'Rahul Kumar','10','A','23',NULL,NULL,NULL,'2025-12-30 05:56:19'),(5,7,'Test Student','10','A','01',NULL,NULL,NULL,'2025-12-31 06:14:32');
/*!40000 ALTER TABLE `students` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `teachers`
--

DROP TABLE IF EXISTS `teachers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `teachers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `subject` varchar(50) DEFAULT NULL,
  `phone` varchar(15) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `teachers_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `teachers`
--

LOCK TABLES `teachers` WRITE;
/*!40000 ALTER TABLE `teachers` DISABLE KEYS */;
INSERT INTO `teachers` VALUES (7,6,'Mr. Sharma','Mathematics',NULL,'2025-12-30 08:14:45');
/*!40000 ALTER TABLE `teachers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('student','teacher','admin') NOT NULL,
  `status` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Table structure for table `sections`
--

DROP TABLE IF EXISTS `sections`;
CREATE TABLE `sections` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(10) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Table structure for table `timetable`
--

DROP TABLE IF EXISTS `timetable`;
CREATE TABLE `timetable` (
  `id` int NOT NULL AUTO_INCREMENT,
  `section_id` int NOT NULL,
  `day` varchar(20) NOT NULL,
  `period` int NOT NULL,
  `subject` varchar(50) NOT NULL,
  `teacher_name` varchar(100) NOT NULL,
  `start_time` varchar(20) NOT NULL,
  `end_time` varchar(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_slot` (`section_id`,`day`,`period`),
  CONSTRAINT `fk_timetable_section` FOREIGN KEY (`section_id`) REFERENCES `sections` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (3,'student@test.com','$2b$10$ieYxl7qwbvcgCq3h95L6L.mt/XrxYQJ3Z.HEm0i6tGtg2VtWD6QVa','student',1,'2025-12-30 05:50:58'),(6,'teacher@test.com','$2b$10$me10Kuns/JRLrM0ERdS27u8/E47.BjrXZM2Kwte45dKvbc17iFz86','teacher',1,'2025-12-30 08:11:05'),(7,'test@student.com','$2b$10$70Ru/Z1ZbMVsbiYlfeMZKe/eXWTXkalwMEEY.yAmqGm.DAt31gZuO','student',1,'2025-12-31 06:14:07');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-01-03  8:54:46
