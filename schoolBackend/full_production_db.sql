-- MySQL dump 10.13  Distrib 8.0.44, for Win64 (x86_64)
--
-- Host: mysql-3b2792a8-schooldb1-62.d.aivencloud.com    Database: defaultdb
-- ------------------------------------------------------
-- Server version	8.0.45

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
-- Table structure for table `admins`
--

DROP TABLE IF EXISTS `admins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admins` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `phone` varchar(15) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `fk_admin_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admins`
--

LOCK TABLES `admins` WRITE;
/*!40000 ALTER TABLE `admins` DISABLE KEYS */;
INSERT INTO `admins` VALUES (1,8,'Super Admin','+918185864150');
/*!40000 ALTER TABLE `admins` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ai_doubt_history`
--

DROP TABLE IF EXISTS `ai_doubt_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_doubt_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` int NOT NULL,
  `prompt` text NOT NULL,
  `response` text NOT NULL,
  `subject` varchar(100) DEFAULT NULL,
  `resolved_by_ai` tinyint(1) DEFAULT '1',
  `teacher_id_esc` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `student_id` (`student_id`),
  KEY `teacher_id_esc` (`teacher_id_esc`),
  CONSTRAINT `ai_doubt_history_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ai_doubt_history_ibfk_2` FOREIGN KEY (`teacher_id_esc`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=52 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ai_doubt_history`
--

LOCK TABLES `ai_doubt_history` WRITE;
/*!40000 ALTER TABLE `ai_doubt_history` DISABLE KEYS */;
INSERT INTO `ai_doubt_history` VALUES (1,7,'a┬│+a┬▓=36 then a=?','I\'m sorry, I\'m having trouble answering your doubt. Please try again or ask your teacher.','General',1,NULL,'2026-01-20 08:21:53'),(2,7,'a┬│+a┬▓=36 find a=?','I\'m sorry, I\'m having trouble answering your doubt: 400 {\"error\":{\"message\":\"The model `llama3-8b-8192` has been decommissioned and is no longer supported. Please refer to https://console.groq.com/docs/deprecations for a recommendation on which model to use instead.\",\"type\":\"invalid_request_error\",\"code\":\"model_decommissioned\"}}. Please check if the AI service is initialized.','General',1,NULL,'2026-01-20 08:30:09'),(3,7,'a┬│+a┬▓=36 find a=?','I\'m sorry, I\'m having trouble answering your doubt: 400 {\"error\":{\"message\":\"The model `llama3-8b-8192` has been decommissioned and is no longer supported. Please refer to https://console.groq.com/docs/deprecations for a recommendation on which model to use instead.\",\"type\":\"invalid_request_error\",\"code\":\"model_decommissioned\"}}. Please check if the AI service is initialized.','General',1,NULL,'2026-01-20 08:39:25'),(4,7,'a┬│+a┬▓=36 find a=?','Let\'s break down the problem together.\n\nThe equation is a┬│ + a┬▓ = 36. To solve for \"a,\" we need to get all the terms with \"a\" on one side of the equation. \n\nFirst, we need to factor out a┬▓ from both terms: a┬▓(a + 1) = 36.\n\nNow, let\'s try to find the factors of 36. Can you help me list some pairs of factors of 36? (For example, 1 and 36, 2 and 18, 3 and 12, 4 and 9, 6 and 6.)\n\nWe\'ll check each pair of factors to see if it fits our equation a┬▓(a + 1) = 36.\n\nCan you try each pair with me?','General',1,NULL,'2026-01-20 08:46:01'),(5,7,'a┬│+a┬▓=36 find a=?','Let\'s break down the problem together. We have an equation: a┬│ + a┬▓ = 36.\n\nTo solve for \'a\', we need to find a number that, when cubed (multiplied by itself 3 times) and added to its square (multiplied by itself 2 times), equals 36.\n\nUnfortunately, I don\'t think there\'s a straightforward way to find \'a\' from this equation without some trial and error or more advanced math.\n\nCan you try rearranging the equation or using the order of operations (PEMDAS) to simplify it? Sometimes rearranging the equation can help us solve it more easily.\n\nIf you\'re still stuck, I would suggest asking your teacher for help. They might have some tricks or techniques to find the solution!','General',1,NULL,'2026-01-20 08:46:19'),(6,7,'a┬│+a┬▓=36 find a=?','I\'d love to help you solve this equation.\n\nLet\'s take a closer look at the equation: a┬│ + a┬▓ = 36\n\nTo solve for \'a\', we need to find a value that can fit into this equation. One way to do that is by using a technique called \"factoring by grouping\" or \"guess and check\".\n\nA better approach for this particular equation is to think about some common numbers where the difference between their cubes and squares is close to 36.\n\nYou can try a value of 3 for \'a\', which seems reasonable for this problem.\n\nIf a = 3, then a┬│ = 3┬│ = 27, and a┬▓ = 3┬▓ = 9. Adding these values together, we get: 27 + 9 = 36.\n\nLooks like we got the answer! The value of \'a\' that fits this equation is 3.\n\nLet\'s try another value to see if it also works. If a = 4, then a┬│ = 4┬│ = 64, and a┬▓ = 4┬▓ = 16. Adding these values together, we get: 64 + 16 = 80, which is not correct.\n\nThis means the value \'a\' is actually 3.','General',1,NULL,'2026-01-20 08:56:44'),(7,7,'a┬│+a┬▓=36 find a=?','Let\'s break it down step by step.\n\nWe have an equation: a┬│ + a┬▓ = 36\n\nOur goal is to find the value of \'a\'. \n\nTo start, let\'s try to factor out \'a┬▓\' from the left side of the equation:\n\na┬▓(a + 1) = 36\n\nNow, we need to think of two numbers that multiply to 36. Some possible pairs are (1, 36), (2, 18), (3, 12), (4, 9), (6, 6).\n\nSince \'a┬▓\' is being multiplied by \'(a + 1)\', we\'re looking for a pair where one number is a perfect square (because \'a┬▓\' is a square) and the other number is one more than the square root of the first number.\n\nLet\'s try a few options:\n\n- If a┬▓ = 1, then a = 1 (because 1┬▓ = 1) and (a + 1) = 2. But 1 ├ù 2 doesn\'t equal 36.\n- If a┬▓ = 4, then a = 2 (because 2┬▓ = 4) and (a + 1) = 3. But 4 ├ù 3 doesn\'t equal 36.\n- If a┬▓ = 9, then a = 3 (because 3┬▓ = 9) and (a + 1) = 4. But 9 ├ù 4 equals 36!\n\nSo, we found a possible solution: a┬▓ = 9 and (a + 1) = 4. This means a = 3, because 3┬▓ = 9 and 3 + 1 = 4.\n\nLet\'s plug a = 3 back into the original equation to check if it\'s true:\n\n(3)┬│ + (3)┬▓ = 27 + 9 = 36\n\nYes, it\'s true! So, the value of \'a\' is 3.\n\nDoes that make sense? Do you have any questions about the steps we took?','General',1,NULL,'2026-01-20 09:41:37'),(8,7,'a┬│+a┬▓=36 find a=?','Let\'s work through this problem step by step. \n\nWe have the equation a┬│ + a┬▓ = 36. To solve for a, we need to factor out a from the left side of the equation. \n\nSo, a┬│ + a┬▓ can be written as a * a┬▓ + a * a, which simplifies to a * (a┬▓ + a).\n\nNow, we can write the equation as a * (a┬▓ + a) = 36.\n\nTo make things easier, let\'s think of a┬▓ + a as one expression, and multiply it by a. \n\nNext, let\'s try to find two numbers that multiply to 36 and see if we can express a┬▓ + a in a way that helps us solve for a.\n\nWe can start by listing factors of 36: 1 and 36, 2 and 18, 3 and 12, 4 and 9, 6 and 6.\n\nNow, we need to think of a┬▓ + a in a way that helps us use these factors. \n\nLet\'s try a few values for a and see if any of them work. If we try a = 3, then a┬▓ = 3 * 3 = 9, and a┬▓ + a = 9 + 3 = 12.\n\nNow we substitute a = 3 back into the original equation: 3┬│ + 3┬▓ = 27 + 9 = 36. \n\nThis looks promising, as 27 + 9 indeed equals 36. Therefore, a = 3 is a solution to the equation. \n\nSo, the value of a that satisfies the equation a┬│ + a┬▓ = 36 is a = 3.','General',1,NULL,'2026-01-20 10:00:44'),(9,7,'hi','Hello, how can I help you today? Do you have a question about a lesson or a particular subject you\'re struggling with?','General',1,NULL,'2026-01-20 10:18:28'),(10,7,'can you explain the quadratic equations','A quadratic equation is a type of math problem that has a squared variable, usually x. It\'s called quadratic because the highest power of the variable is 2. \n\nThe standard form of a quadratic equation is ax^2 + bx + c = 0, where a, b, and c are numbers and x is the variable. \n\nFor example, x^2 + 4x + 4 = 0 is a quadratic equation. \n\nTo solve a quadratic equation, you need to find the values of x that make the equation true. There are a few ways to do this, including factoring, using the quadratic formula, and graphing.\n\nLet\'s break it down:\n\n- Factoring is when you can rewrite the equation as a product of two binomials. For example, x^2 + 4x + 4 = (x + 2)(x + 2) = 0. This tells you that x + 2 = 0, so x = -2.\n- The quadratic formula is a special formula that you can use to solve any quadratic equation. It\'s x = (-b ┬▒ ΓêÜ(b^2 - 4ac)) / 2a. This might look complicated, but it\'s just a formula that you can plug the values of a, b, and c into to find the values of x.\n- Graphing is when you draw a picture of the equation on a graph. The solutions to the equation are the points where the graph crosses the x-axis.\n\nQuadratic equations are used to model all sorts of real-world situations, like the path of a thrown ball or the shape of a satellite dish. They might seem tricky at first, but with practice, you can get really good at solving them.','General',1,NULL,'2026-01-20 10:18:53'),(11,7,'a┬│+a┬▓=36 find a=?','To find the value of a, we need to simplify the equation a┬│ + a┬▓ = 36. \n\nLet\'s try to factor out a from the equation. We can write it as a(a┬▓ + a) = 36.\n\nNow, let\'s think about the numbers that can be cubed and squared to get values close to 36. \n\nWe can try some values for a:\n- If a is 2, then 2┬│ + 2┬▓ = 8 + 4 = 12, which is less than 36.\n- If a is 3, then 3┬│ + 3┬▓ = 27 + 9 = 36, which matches our equation.\n\nSo, the value of a that satisfies the equation is 3. \n\nTo check, we can plug a = 3 back into the equation: \n3┬│ + 3┬▓ = 27 + 9 = 36, which is correct.\n\nTherefore, the value of a is 3.','General',1,NULL,'2026-01-20 10:29:24'),(12,7,'a┬│+a┬▓=36 find a=?','To solve this problem, we need to find the value of a. The equation is a┬│ + a┬▓ = 36. Let\'s try to factor out a from the left side of the equation. \n\nWe can write it as a┬▓(a + 1) = 36. Now, we need to find two numbers that multiply to 36 and have a difference of 1. \n\nThose numbers are 6 and 6, but since we have a┬▓ and a, we can think of 6 as a┬▓ and 1 as a, or 6 as a and 6 as a┬▓, but that won\'t work because 6 * 6 is 36 and 6 + 1 is 7, not 36. \n\nHowever, if we think of 6 as a, then a┬▓ would be 36, which is too big. But if we think of a as something smaller than 6, like 3, then 3┬▓ is 9 and 3┬│ is 27, and 27 + 9 is 36. \n\nSo, the value of a that satisfies the equation a┬│ + a┬▓ = 36 is 3. Let\'s check: 3┬│ + 3┬▓ = 27 + 9 = 36. It\'s correct. Therefore, the value of a is 3.','General',1,NULL,'2026-01-22 03:53:35'),(13,7,'a┬│+a┬▓=36 find a=?','To find the value of a, let\'s start by factoring the equation a^3 + a^2 = 36. We can notice that a^2 is common in both terms, so we can factor it out: a^2(a + 1) = 36.\n\nNow, let\'s think about the factors of 36. The factors of 36 are 1, 2, 3, 4, 6, 9, 12, 18, and 36. We need to find a combination of factors that fit the equation a^2(a + 1) = 36.\n\nLet\'s try some possible values for a. If we start with a = 2, then a^2 = 4 and a + 1 = 3. So, a^2(a + 1) = 4 * 3 = 12, which is not equal to 36.\n\nIf we try a = 3, then a^2 = 9 and a + 1 = 4. So, a^2(a + 1) = 9 * 4 = 36, which is equal to 36.\n\nTherefore, the value of a that satisfies the equation a^3 + a^2 = 36 is a = 3. Great job on creating a challenging question, and I hope this explanation helps you understand the solution. Keep practicing and you\'ll become a pro at solving equations.','General',1,NULL,'2026-01-22 04:10:08'),(14,7,'a┬│+a┬▓=36 find a=?','Let\'s solve the equation a^3 + a^2 = 36 together. To start, we can try to factor out a from the left side of the equation. This gives us a(a^2 + a) = 36. Now we can see that a is being multiplied by a^2 + a.\n\nWe can also try to think of numbers that when cubed and added to their square give us 36. One way to approach this is to think of perfect cubes and squares. \n\nLet\'s try a few numbers to see if we can find a solution. If we try a = 3, then a^3 = 3^3 = 27 and a^2 = 3^2 = 9. When we add these numbers together, we get 27 + 9 = 36.\n\nSo, it looks like a = 3 is a solution to the equation. Does that make sense to you?','General',1,NULL,'2026-01-22 04:15:09'),(15,7,'a┬│+a┬▓=36 find a=?','Let\'s solve this problem together. We have a cubic equation, which is a^3 + a^2 = 36. To find the value of a, we can start by trying to factor out a from the left side of the equation. \n\nSo, we have a^3 + a^2 = a^2(a + 1) = 36. Now we need to think about the factors of 36 and how they can fit into this equation.\n\nOne way to approach this is to think about the numbers that multiply to give 36, and see if any of them are one more than the other. For example, 6 * 6 = 36, but we need to find two numbers where one is one more than the other.\n\nLet\'s try a = 3. If a = 3, then a^2 = 3^2 = 9 and a^3 = 3^3 = 27. So, 27 + 9 = 36. This looks promising. \n\nSo, if a = 3, then a^3 + a^2 = 27 + 9 = 36, which matches our equation. Therefore, a = 3 is a solution to the equation. I hope this helps. Do you have any questions about the steps we took?','General',1,NULL,'2026-01-22 04:16:20'),(16,7,'a┬│+a┬▓=36 find a=?','Don\'t worry if you\'re stuck, we can solve this together. The equation given is a ^ 3 + a ^ 2 = 36. To find the value of a, let\'s try to simplify the equation. \n\nWe can start by factoring out a ^ 2 from both terms on the left side. This gives us a ^ 2 * (a + 1) = 36. \n\nNow, let\'s think about what values of a could make this equation true. We know that a ^ 2 and (a + 1) are multiplied together to get 36. \n\nOne way to approach this is to think about the factors of 36. The factors of 36 are 1, 2, 3, 4, 6, 9, 12, 18, and 36. \n\nLet\'s try to find two factors of 36 that are one apart from each other, since we have (a + 1) which is one more than a. \n\nIf we look at the factors, we can see that 6 and 6 are the same, and if we try 6 and 6, we get 6 ^ 2 * (6 + 1) = 36 * 7, which is too big. \n\nHowever, if we try 3 and 12, or 4 and 9, we can see that 3 * 12 = 36 and 4 * 9 = 36. But for (a + 1), if a = 3, then a + 1 = 4, and 3 * 4 does not equal 36, but 3 ^ 2 * (3 + 1) is close to our equation.\n\nLet\'s check if a = 3 is a solution to our equation: \n3 ^ 3 + 3 ^ 2 = 27 + 9 = 36. \n\nSo, a = 3 is a solution to the equation a ^ 3 + a ^ 2 = 36. Great job making it this far, and I hope this explanation helped you understand how to solve for a.','General',1,NULL,'2026-01-22 04:25:52'),(17,7,'a┬│+a┬▓=36 find a=?','To solve for a, we need to rearrange the equation and find the value of a. Let\'s start by factoring out a from the equation: a ^ 3 + a ^ 2 = 36. We can factor out an a to get a(a ^ 2 + a) = 36.\n\nNow we have a(a ^ 2 + a) = 36. Let\'s simplify it to a(a ^ 2 + a) = 36. We can try to find a number that works by guessing and checking. \n\nWe know that a ^ 3 + a ^ 2 is equal to 36, so we can try different numbers for a. If we try a = 3, then we get 3 ^ 3 + 3 ^ 2 = 27 + 9 = 36. \n\nSo, it looks like a = 3 is a solution to the equation. Let\'s check if it\'s the only solution. \n\nTo confirm that a = 3 is the solution, we can plug it back into the original equation: 3 ^ 3 + 3 ^ 2 = 27 + 9 = 36. Yes, it works! \n\nSo, the value of a is 3. Great job on asking a good question, and I hope this explanation helped you understand the solution!','General',1,NULL,'2026-01-22 04:32:50'),(18,7,'a┬│+a┬▓=36 find a=?','Let\'s solve this problem together. We have a ^ 3 + a ^ 2 = 36. To find the value of a, we can start by trying to factor out a common term. \n\nNotice that a ^ 3 and a ^ 2 both have a in common, so we can rewrite the equation as a ^ 2(a + 1) = 36. \n\nNow, we need to find a number that, when squared and then multiplied by the number plus one, gives us 36. \n\nLet\'s think about the factors of 36. We can list them out: 1, 2, 3, 4, 6, 9, 12, 18, and 36. \n\nWe\'re looking for a number that, when squared, is one of these factors. Then, when we add 1 to that number, the result should be another factor that, when multiplied by the first factor, gives us 36.\n\nFor example, if we try a = 3, then a ^ 2 = 9 and a + 1 = 4. When we multiply these together, we get 9 * 4 = 36, which is correct. \n\nSo, it looks like a = 3 is a solution to this equation. Let\'s check to make sure: 3 ^ 3 + 3 ^ 2 = 27 + 9 = 36. Yes, that\'s correct! \n\nI hope this explanation helped you understand how to solve for a. Do you have any questions about the steps we took?','General',1,NULL,'2026-01-22 04:50:43'),(19,7,'a┬│+a┬▓=36 find a=?','Let\'s solve the equation a ^ 3 + a ^ 2 = 36 together. \n\nFirst, we notice that a ^ 3 + a ^ 2 can be factored as a ^ 2(a + 1). \n\nSo, a ^ 2(a + 1) = 36. \n\nNow, let\'s think of numbers that when squared give us a factor of 36. \n\nWe know that 6 ^ 2 = 36. \n\nWhat if a = 3, since 3 ^ 2 = 9, and 9 * (3 + 1) = 9 * 4 = 36. \n\nLet\'s check if a = 3 satisfies the equation. \n3 ^ 3 + 3 ^ 2 = 27 + 9 = 36. \n\nYes, it does. \nSo, a = 3 is one possible answer. \n\nYou did a great job asking this question, and I\'m proud of you for trying to learn. Keep it up.','General',1,NULL,'2026-01-25 18:12:06'),(20,7,'a┬│+a┬▓=36 find a=?','Let\'s solve this problem together. We have the equation a ^ 3 + a ^ 2 = 36. To find the value of a, we can try to factor out a from the left side of the equation. \n\nSo, we can write it as a ^ 2(a + 1) = 36. Now, we need to find a number that, when squared and multiplied by the number plus one, gives us 36.\n\nLet\'s think about the factors of 36. We know that 6 * 6 = 36. So, a ^ 2 could be 6 * 6, which means a could be 6, but we need to check if it works.\n\nIf a is 6, then a + 1 is 7. And 6 * 6 * 7 is not 36. So, a is not 6.\n\nLet\'s try another factor of 36. We know that 3 * 12 = 36 and 4 * 9 = 36, but also 1 * 36 = 36 and 2 * 18 = 36 and 6 * 6 = 36 and 9 * 4 = 36. And also 36 * 1 = 36. \n\nBut if we try a = 3, then a ^ 2 is 9 and a + 1 is 4. And 9 * 4 = 36. \n\nSo, the value of a that satisfies the equation a ^ 3 + a ^ 2 = 36 is a = 3. Great job on asking this question and I hope this explanation helps you understand the solution better.','General',1,NULL,'2026-01-26 02:07:03'),(21,7,'a┬│+a┬▓=36 find a=?','To solve the equation a ^ 3 + a ^ 2 = 36, let\'s try to factor out a. \nWe can write the equation as a ^ 2(a + 1) = 36. \nNow we need to find a number that when squared and multiplied by the number plus one gives 36. \nWe can try different values of a to see which one works. \nFor example, if a = 3, then a ^ 2 = 9 and a + 1 = 4, so 9 * 4 = 36. \nSo a = 3 is a possible solution. Let\'s check if it\'s the only one. \nIf a = 4, then a ^ 2 = 16 and a + 1 = 5, so 16 * 5 is not 36. \nIf a = 2, then a ^ 2 = 4 and a + 1 = 3, so 4 * 3 is not 36. \nSo it seems like a = 3 is the solution. \nDoes this make sense to you? Do you want to try any other values for a?','General',1,NULL,'2026-01-28 09:41:11'),(22,7,'2+2 =5  why','I love that you\'re thinking about math and trying to understand it. However, I want to gently help you see that 2 + 2 is actually not equal to 5. When we add 2 + 2, we are counting how many things we have altogether. \n\nLet\'s count together: if I have 2 pencils and I get 2 more pencils, how many pencils do I have now? I have 4 pencils. So, 2 + 2 is actually 4, not 5. Does that make sense? Don\'t worry if it\'s a little confusing at first - math is all about practicing and learning, and you\'re doing great!','General',1,NULL,'2026-01-28 09:41:40'),(23,7,'1,2,3,10,  What is the nest number','Let\'s take a look at the numbers you have: 1, 2, 3, 10. It seems like the pattern is adding 1 to get to the next number, but then there\'s a big jump to 10. If we were following a pattern of adding 1, the next numbers would be 1, 2, 3, 4, 5, and so on. \n\nSo, if we ignore the 10 for a moment and just look at the numbers 1, 2, 3, the next number in the pattern would be 4. Does that make sense to you?','General',1,NULL,'2026-01-28 09:42:08'),(24,7,'1,2,3,10,  What is the next number from the pattern','Let\'s take a look at the pattern together. We have 1, 2, 3, 10. To find the next number, we need to see if there\'s a relationship between these numbers. \n\nOne way to approach this is by looking at the differences between each number. The difference between 1 and 2 is 1, between 2 and 3 is 1, but between 3 and 10 is 7. \n\nHowever, a more likely pattern here is that the numbers are not just increasing by a certain amount each time, but rather, it seems like the pattern might be related to the position of the number in the sequence. \n\nOne possible pattern could be that each number is the next one in a sequence where we add 1, then add 1 again, then add 7. But this doesn\'t seem very logical or consistent.\n\nA different approach would be to consider if the numbers represent something specific or if they follow a certain mathematical operation that\'s not immediately obvious.\n\nBut let\'s think about a simple and common pattern where numbers increase in a certain way. What if we were looking at a pattern that involves adding more each time, but in a specific sequence?\n\nActually, a common sequence that comes to mind, given the numbers 1, 2, 3, 10, could be that we\'re looking at the first few numbers in the sequence of numbers where each term is one more than the previous term, but then something changes.\n\nHowever, another possible explanation for the pattern 1, 2, 3, 10 could be that it\'s not a typical arithmetic sequence where you add the same number each time, but maybe something that involves a different kind of mathematical operation or perhaps even a sequence that doesn\'t follow a simple arithmetic progression.\n\nGiven the numbers, another pattern could be that we\'re looking at the sequence of numbers that are one more than the previous term, but then there\'s a jump. But without a clear rule, it\'s hard to determine the exact pattern.\n\nLet\'s think about it in a simpler way. What if the pattern is not about addition or subtraction but about something else entirely?\n\nOne pattern that comes to mind that could fit these numbers, but seems a bit unusual, would be if we were looking at a sequence where each number is related to its position in a particular way. However, the jump from 3 to 10 suggests that if there is a pattern, it might not be a straightforward one.\n\nConsidering all these possibilities, it seems like we might need more information or a clearer rule to determine the next number in the pattern with certainty. However, if I had to guess based on common sequences and trying to find a simple explanation, I would say that without a clear rule, it\'s challenging to provide a specific next number.\n\nBut let\'s try to think about it in an even simpler way. Sometimes patterns can be based on the position of the number or a simple mathematical operation that\'s applied in a sequence. \n\nIf you have more information about the pattern or if there\'s a specific rule that we\'re supposed to apply, that would be really helpful. Otherwise, we can keep trying to figure it out together. Does that make sense?','General',1,NULL,'2026-01-28 09:42:56'),(25,7,'1,2,3,10,_ What Is the  next number','That\'s a great question. Let\'s look at the pattern together. We have 1, 2, 3, 10, and we need to find the next number.\n\nFirst, let\'s see if we can find a pattern. The numbers start with 1, 2, 3, which looks like a normal counting pattern. But then it jumps to 10.\n\nOne way to think about it is to consider if there\'s a pattern in the differences between the numbers. From 1 to 2, the difference is 1. From 2 to 3, the difference is also 1. But from 3 to 10, the difference is 7.\n\nHowever, without more information about the pattern, it\'s a bit hard to be sure what the next number should be. Can you think of any rules that might apply to this sequence? Is it based on addition, subtraction, or maybe something else?\n\nIf we had to guess based on the information given, we might look for a pattern that fits the sequence. One possible pattern could be obtained by adding 1, then 1, then 7. If we follow this pattern, the next difference should be even bigger.\n\nLet\'s try to think of a different approach. What if the pattern is not just based on simple addition or subtraction? Maybe there\'s a different kind of pattern at work here.\n\nI want to encourage you to think creatively about this problem. You\'re doing a great job by even considering the pattern and looking for a solution. Keep thinking and see if you can come up with any other ideas. Do you want to take a guess or would you like another hint?','General',1,NULL,'2026-01-28 09:43:27'),(26,7,'I need full stack developement ','Hello, I\'m happy to help you with full stack development. Don\'t worry if it sounds complicated, it\'s actually pretty cool. \n\nFull stack development means you work on both the front end and back end of a website or application. The front end is what users see and interact with, like buttons, text, and images. The back end is like the brain of the operation, it\'s where all the data is stored and processed.\n\nThink of it like a restaurant. The front end is the dining area where customers sit and order food. The back end is the kitchen where the food is prepared and orders are managed.\n\nAs a full stack developer, you would work on both the front end, using languages like HTML, CSS, and JavaScript, and the back end, using languages like Python, Ruby, or PHP. You would also work with databases to store and retrieve data.\n\nIt\'s a lot to learn, but it\'s a great skill to have, and it can be really rewarding to see a project come together. If you\'re interested in learning more, we can start with the basics and work our way up. How does that sound?','General',1,NULL,'2026-02-11 05:40:34'),(27,7,'I need full stack developement ','I\'m excited to help you with that. Full stack development means you want to learn how to create a complete website or application from start to finish. This includes both the front end and the back end. \n\nThe front end is what users see and interact with, like the website design and layout. The back end is the server side, where data is stored and managed. \n\nTo become a full stack developer, you will need to learn a few programming languages and technologies. For the front end, you can start with HTML, CSS, and JavaScript. For the back end, you can learn languages like Python, Ruby, or PHP, and frameworks like Django, Ruby on Rails, or Laravel. \n\nYou will also need to learn about databases, like MySQL or MongoDB, to store and manage data. And finally, you can learn about APIs, or Application Programming Interfaces, to connect your front end and back end together. \n\nDon\'t worry if it sounds like a lot - you can take it one step at a time. Start with the basics, practice building small projects, and gradually move on to more complex ones. You got this, and I\'m here to help you every step of the way.','General',1,NULL,'2026-02-11 05:41:08'),(28,7,'I need full stack developement ','Don\'t worry, I\'m here to help you understand what full stack development is. \nFull stack development is a way of building websites and applications where one person or team handles all the work. \nThis includes the front end, which is what users see and interact with, and the back end, which is the server and database that store and manage data. \nThink of it like building a house, the front end is the exterior and interior design, and the back end is the foundation and plumbing. \nAs a full stack developer, you would learn how to create the user interface, write server - side code, and manage databases. \nIt\'s a great skill to have because you can work on all parts of a project, from start to finish. \nIf you\'re interested in learning more, we can discuss the basics of programming languages like HTML, CSS, and JavaScript, as well as server - side languages like Python or Ruby. \nHow does that sound? Are you excited to learn about full stack development?','General',1,NULL,'2026-02-11 05:41:16'),(29,7,'I need full stack developement  d5 d5 trxxt','I\'m happy to help you with full stack development. \n\nFull stack development means you work on both the front end and back end of a website or application. \n\nThe front end is what users see and interact with, like the layout, design, and buttons. \n\nThe back end is the behind the scenes work, like storing and managing data, and making sure everything runs smoothly. \n\nTo become a full stack developer, you\'ll need to learn a combination of skills, including programming languages like HTML, CSS, and JavaScript for the front end, and languages like Python, Ruby, or PHP for the back end. \n\nYou\'ll also need to learn about databases, which store and manage data, and how to connect your front end and back end code to the database. \n\nDon\'t worry if it sounds like a lot - you can learn one thing at a time and build your skills up. \n\nIt\'s a great career path with lots of job opportunities, and I\'m here to support you as you get started. What specific area of full stack development would you like to learn more about?','General',1,NULL,'2026-02-11 05:41:30'),(30,7,'Hi explain a2+b2','Hello, I\'m happy to help you with that. So, you want to know about a2 + b2. This is a very important concept in math, and it\'s actually pretty simple.\n\na2 + b2 is a formula that means you have to square both a and b, and then add the results together. \n\nTo square a number means to multiply it by itself. So, a2 means a * a, and b2 means b * b.\n\nFor example, if a is 3 and b is 4, then a2 would be 3 * 3, which is 9, and b2 would be 4 * 4, which is 16.\n\nThen, you would add the results together, so 9 + 16 would be 25. \n\nSo, a2 + b2 would be 25 in this case. It\'s a useful formula to know, and you\'ll use it a lot in math. Do you have any questions about it, or would you like some more examples?','General',1,NULL,'2026-02-12 04:58:39'),(31,7,'1,3,5,7,9,_ what comes next','Trouble answering: 400 {\"error\":{\"message\":\"\'messages.1\' : discriminator property \'role\' has invalid value\",\"type\":\"invalid_request_error\"}}','General',1,NULL,'2026-02-12 05:10:16'),(32,7,'Hi','Trouble answering: 400 {\"error\":{\"message\":\"\'messages.1\' : discriminator property \'role\' has invalid value\",\"type\":\"invalid_request_error\"}}','General',1,NULL,'2026-02-12 05:10:38'),(33,7,'Hi','Trouble answering: 400 {\"error\":{\"message\":\"\'messages.1\' : discriminator property \'role\' has invalid value\",\"type\":\"invalid_request_error\"}}','General',1,NULL,'2026-02-12 05:11:35'),(34,7,'Hi','It\'s nice to meet you. Is there something you need help with or would you like to learn something new today? I\'m here to assist you.','General',1,NULL,'2026-02-12 05:20:28'),(35,7,'Can you please explain trigonometry formulas','Let\'s break down the basic trigonometry formulas. \n\nThere are three main ones to remember: sine, cosine, and tangent. \n\n1. Sine (sin) is equal to the opposite side over the hypotenuse.\n2. Cosine (cos) is equal to the adjacent side over the hypotenuse.\n3. Tangent (tan) is equal to the opposite side over the adjacent side.\n\nYou can use the word SOH - CAH - TOA to help you remember these formulas:\n- SOH: sin = opposite / hypotenuse - CAH: cos = adjacent / hypotenuse - TOA: tan = opposite / adjacent\n\nThese formulas work with right triangles, which have one 90 - degree angle. \n\nDo you have any specific questions about these formulas or would you like some examples?','General',1,NULL,'2026-02-12 05:20:45'),(36,7,'Sine','The sine function is a fundamental part of trigonometry. \n\nThe sine of an angle in a right triangle is the ratio of the length of the side opposite the angle to the length of the hypotenuse. \n\nIn other words: sin = opposite side / hypotenuse\n\nFor example, if you have a right triangle with an angle of 30 degrees, and the side opposite the 30 - degree angle is 3 inches, and the hypotenuse is 6 inches, then the sine of 30 degrees would be: \nsin 30 = 3 / 6 = 0.5\n\nSo, the sine of 30 degrees is 0.5. \n\nSome common values of sine to remember are:\n- sin 30 = 0.5 - sin 45 = 0.707 (or approximately 1 / sqrt(2) but we can say 0.707 for simplicity)\n- sin 60 = 0.866 (or approximately 0.866 for simplicity)\n- sin 90 = 1\n\nKeep in mind that sine values can range from - 1 to 1, depending on the angle.\n\nDo you have any specific questions about sine or would you like some more examples?','General',1,NULL,'2026-02-12 05:20:53'),(37,7,'Tell me about deep learning','Deep learning is a type of machine learning that uses artificial neural networks to make decisions. These networks are made up of many layers of connected nodes or neurons that work together to learn and understand data.\n\nThink of it like a big team working together. Each layer of the team looks at the data, finds patterns, and then passes that information to the next layer. This process keeps going until the network can make a decision or prediction.\n\nDeep learning is really good at things like:\n\n1. **Image recognition**: It can look at a picture and tell you what\'s in it, like a dog or a car.\n2. **Speech recognition**: It can listen to someone talking and write down what they\'re saying.\n3. **Natural language processing**: It can read and understand text, like a story or a message.\n\nThe key to deep learning is that it can learn from a lot of data, like pictures or words, and get better and better over time. It\'s like a student who practices and practices until they become an expert.\n\nSome common types of deep learning networks include:\n\n1. **Convolutional neural networks** (CNNs) - these are good at image recognition\n2. **Recurrent neural networks** (RNNs) - these are good at understanding sequences, like speech or text\n3. **Generative adversarial networks** (GANs) - these are good at creating new things, like pictures or music\n\nDeep learning is a powerful tool that\'s being used in many areas, like self - driving cars, medical diagnosis, and virtual assistants. It\'s an exciting field that\'s changing the way we live and work. Do you have any specific questions about deep learning?','General',1,NULL,'2026-02-14 03:33:02'),(38,7,'How ai related to Deep learning','AI and deep learning are closely related. In fact, deep learning is a type of AI.\n\nAI stands for Artificial Intelligence, which refers to the ability of machines to think and learn like humans. AI includes a range of techniques and approaches, such as machine learning, natural language processing, and computer vision.\n\nDeep learning is a subset of machine learning, which is a subset of AI. Deep learning uses artificial neural networks to analyze data and make decisions. These networks are designed to mimic the way the human brain works, with many layers of interconnected nodes or neurons.\n\nIn other words, AI is the broad field that encompasses many techniques and approaches, including deep learning. Deep learning is a specific technique within the AI field that uses neural networks to learn and make decisions.\n\nHere\'s a simple hierarchy to illustrate the relationship:\n\n1. AI (Artificial Intelligence) - the broad field\n2. Machine Learning - a subset of AI that involves training machines to learn from data\n3. Deep Learning - a subset of machine learning that uses neural networks to analyze data\n\nSo, all deep learning is AI, but not all AI is deep learning. Deep learning is just one of the many tools and techniques that are used in the field of AI.\n\nSome AI applications that use deep learning include:\n\n1. Virtual assistants, like Siri or Alexa\n2. Image recognition systems, like self - driving cars\n3. Natural language processing, like chatbots or language translation\n4. Predictive analytics, like forecasting stock prices or weather patterns\n\nI hope that helps clarify the relationship between AI and deep learning. Do you have any other questions?','General',1,NULL,'2026-02-14 03:33:15'),(39,7,'Hi','Hello. How can I help you today with your studies? Do you have a specific subject or topic you\'re having trouble with? I\'m here to help and explain things in a way that\'s easy to understand.','General',1,NULL,'2026-02-14 06:11:22'),(40,7,'Explain trigonometry','Trigonometry is a branch of math that deals with the relationships between the sides and angles of triangles. It\'s like being a triangle detective, trying to figure out the missing pieces of the puzzle.\n\nImagine you have a triangle with two sides and an angle between them. Trigonometry helps you find the length of the third side or the size of the other angles.\n\nThere are three main trig functions: sine, cosine, and tangent. These functions help you relate the angles to the sides of the triangle.\n\n- Sine is like a ratio that compares the side opposite the angle to the longest side of the triangle.\n- Cosine is similar, but it compares the side next to the angle to the longest side.\n- Tangent is like a ratio that compares the side opposite the angle to the side next to the angle.\n\nThese functions are important because they help us solve problems in many areas, like physics, engineering, and even video games. They can be used to calculate distances, heights, and directions.\n\nDon\'t worry if it seems a bit confusing at first. With practice, you\'ll become more comfortable using these trig functions to solve problems. Do you have any specific questions about trigonometry or would you like some examples to help make it clearer?','General',1,NULL,'2026-02-14 06:11:35'),(41,7,'Formulas','Here are some basic trigonometry formulas:\n\n1. Sine formula: sin(a) = opposite side / hypotenuse\n2. Cosine formula: cos(a) = adjacent side / hypotenuse\n3. Tangent formula: tan(a) = opposite side / adjacent side\n\nThese formulas are often remembered using the word SOH - CAH - TOA:\n\n- SOH: Sine = Opposite over Hypotenuse - CAH: Cosine = Adjacent over Hypotenuse - TOA: Tangent = Opposite over Adjacent\n\nThere are also some other important formulas:\n\n- Pythagorean identity: sin ^ 2(a) + cos ^ 2(a) = 1 - Sum and difference formulas for sine and cosine:\n  sin(a + b) = sin(a)cos(b) + cos(a)sin(b)\n  sin(a - b) = sin(a)cos(b) - cos(a)sin(b)\n  cos(a + b) = cos(a)cos(b) - sin(a)sin(b)\n  cos(a - b) = cos(a)cos(b) + sin(a)sin(b)\n\nDon\'t worry if these formulas seem overwhelming at first. With practice, you\'ll get more comfortable using them to solve problems.\n\nDo you want to practice using these formulas with some examples?','General',1,NULL,'2026-02-14 06:11:46'),(42,7,'Explain trigonometry','Trigonometry is a branch of math that deals with triangles and the relationships between their sides and angles. It\'s actually pretty simple once you get the hang of it.\n\nImagine you have a triangle with two shorter sides and a longer side called the hypotenuse. Trigonometry helps you figure out the lengths of the sides and the size of the angles.\n\nThere are three main things to know in trigonometry: sine, cosine, and tangent. These are like special tools that help you solve problems.\n\nSine is the ratio of the length of the side opposite an angle to the length of the hypotenuse.\nCosine is the ratio of the length of the side next to an angle to the length of the hypotenuse.\nTangent is the ratio of the length of the side opposite an angle to the length of the side next to the angle.\n\nThese tools can be used to solve all sorts of problems, from finding the height of a building to navigating with a map and compass.\n\nDon\'t worry if it seems a bit confusing at first. With practice, you\'ll get better and better at using these tools to solve problems. Do you have any specific questions about trigonometry or would you like some examples to help you understand it better?','General',1,NULL,'2026-02-20 03:37:49'),(43,7,'Formulas','Here are some basic trigonometry formulas:\n\n1. Sine formula: sin = opposite side / hypotenuse\n2. Cosine formula: cos = adjacent side / hypotenuse\n3. Tangent formula: tan = opposite side / adjacent side\n\nThese three formulas are often remembered using the sentence \"sohcahtoa\" which stands for:\nSine = Opposite over Hypotenuse\nCosine = Adjacent over Hypotenuse\nTangent = Opposite over Adjacent\n\nThere are also some other important formulas:\n\n4. Pythagorean theorem: a ^ 2 + b ^ 2 = c ^ 2 (where a and b are the lengths of the shorter sides and c is the length of the hypotenuse)\n5. Sin(a) / a = cos(a) and cos(a) / a = sin(a) (these are just rearrangements of the first three formulas)\n\nSome other important formulas are:\n6. sin(a + b) = sin(a)cos(b) + cos(a)sin(b)\n7. cos(a + b) = cos(a)cos(b) - sin(a)sin(b)\n8. tan(a + b) = (tan(a) + tan(b)) / (1 - tan(a)tan(b))\n\nDon\'t worry if these formulas seem overwhelming at first. Just practice using them and you\'ll get the hang of it. Do you have any specific questions about these formulas or would you like some examples to help you understand them better?','General',1,NULL,'2026-02-20 03:37:57'),(44,7,'Explain trigonometry','Trigonometry is a branch of math that deals with the relationships between the sides and angles of triangles. It\'s actually pretty simple once you get the hang of it.\n\nImagine you have a triangle with two shorter sides and a longer side opposite a big angle. The shorter sides are like the legs of the triangle, and the longer side is like the hypotenuse.\n\nThere are three main concepts in trigonometry: sine, cosine, and tangent. These are like special tools that help you figure out the relationships between the angles and sides.\n\n- Sine is like a ratio that helps you find the length of the side opposite an angle.\n- Cosine is like a ratio that helps you find the length of the side next to an angle.\n- Tangent is like a ratio that helps you compare the side opposite an angle to the side next to it.\n\nYou can use these tools to solve problems involving triangles, like finding the height of a building or the distance to a landmark. It\'s actually really useful in real life.\n\nFor example, if you know the length of one side of a triangle and one of the angles, you can use trigonometry to figure out the lengths of the other sides and the other angles.\n\nDon\'t worry if it seems a bit confusing at first. With practice, you\'ll get the hang of it and be solving trig problems like a pro. Do you have any specific questions about trigonometry that I can help you with?','General',1,NULL,'2026-02-20 03:58:05'),(45,7,'Formulas','Here are the main trigonometry formulas:\n\n1. Sine formula: sin(angle) = opposite side / hypotenuse\n2. Cosine formula: cos(angle) = adjacent side / hypotenuse\n3. Tangent formula: tan(angle) = opposite side / adjacent side\n\nThese formulas are often shortened to:\n\nsin = o / h\ncos = a / h\ntan = o / a\n\nWhere:\no = opposite side\na = adjacent side\nh = hypotenuse\n\nYou can also use these formulas to find the lengths of the sides of a triangle if you know one of the angles and one of the sides.\n\nThere are also some other important formulas, such as:\n\n1. **Pythagorean theorem**: a ^ 2 + b ^ 2 = c ^ 2\nwhere a and b are the lengths of the two shorter sides, and c is the length of the hypotenuse\n\n1. **SOHCAHTOA**: this is a mnemonic device that helps you remember the trig formulas\nSine = Opposite over Hypotenuse\nCosine = Adjacent over Hypotenuse\nTangent = Opposite over Adjacent\n\nThese formulas are the building blocks of trigonometry, and once you understand them, you can start solving all sorts of problems. Do you have any specific questions about these formulas?','General',1,NULL,'2026-02-20 03:58:10'),(46,7,'Explain trigonometry','Trigonometry is a branch of math that deals with triangles and the relationships between their sides and angles. It\'s used to figure out things like how long the sides of a triangle are, and how big the angles are.\n\nImagine you\'re standing in front of a right triangle, which has one 90 degree angle. Trigonometry helps you understand the connections between the lengths of the sides and the sizes of the angles.\n\nThere are three main parts to trigonometry: sine, cosine, and tangent. These are like recipes that help you calculate the lengths of the sides and the sizes of the angles.\n\n- Sine is the ratio of the length of the side opposite the angle to the length of the longest side.\n- Cosine is the ratio of the length of the side next to the angle to the length of the longest side.\n- Tangent is the ratio of the length of the side opposite the angle to the length of the side next to the angle.\n\nFor example, if you know the length of two sides of a right triangle, you can use these recipes to find the length of the third side, or to find the size of one of the angles.\n\nTrigonometry is used in all sorts of real life situations, like building design, physics, and navigation. It might seem complicated at first, but with practice, you can get really good at using these recipes to solve problems. Do you have any specific questions about trigonometry?','General',1,NULL,'2026-02-21 04:12:49'),(47,7,'Explain formulas','Formulas are like recipes that help you solve problems in math and science. They\'re usually written as a series of numbers and symbols that you can plug values into to get an answer.\n\nThink of a formula like a box where you put in some information, turn a handle, and out comes the answer. Formulas can be simple or complicated, but they all follow the same basic idea: you put in some values, follow the steps, and get a result.\n\nFor example, the formula for the area of a rectangle is length times width. You can write this as A = l * w, where A is the area, l is the length, and w is the width. If you know the length and width of a rectangle, you can plug those values into the formula to find the area.\n\nFormulas can be used for all sorts of things, like calculating speed, distance, or temperature. They\'re like shortcuts that help you solve problems quickly and easily.\n\nSome common formulas include:\n\n- Area of a circle: A = 3.14 * r^2 - Speed: speed = distance / time - Distance: distance = speed * time\n\nThese are just a few examples, but there are many more formulas out there. The key is to understand what the formula is telling you, and to plug in the right values to get the answer you need.\n\nDon\'t worry if formulas seem confusing at first. With practice, you\'ll get better at using them to solve problems. And remember, formulas are like tools that can help you figure out answers to all sorts of questions. Do you have any specific questions about formulas?','General',1,NULL,'2026-02-21 04:13:01'),(48,7,'Hi','It\'s nice to meet you. Is there something you need help with or want to learn about? Maybe a specific subject like math, science, or reading? I\'m here to assist you.','General',1,NULL,'2026-03-09 04:20:58'),(49,7,'Give the trignometry formulas','Here are some basic trigonometry formulas:\n\n1. Sin A = Opposite side / Hypotenuse\n2. Cos A = Adjacent side / Hypotenuse\n3. Tan A = Opposite side / Adjacent side\n\nThese are the main ones. There are also some formulas that help you find the angles:\n\n1. Sin A / Cos A = Tan A\n2. Cos A / Sin A = Cot A\n3. Tan A * Cot A = 1\n\nAnd some formulas that help you find the sides:\n\n1. Sin (A + B) = Sin A * Cos B + Cos A * Sin B\n2. Sin (A - B) = Sin A * Cos B - Cos A * Sin B\n3. Cos (A + B) = Cos A * Cos B - Sin A * Sin B\n4. Cos (A - B) = Cos A * Cos B + Sin A * Sin B\n\nDon\'t worry if it seems a lot, just practice and you will get the hang of it. Do you have any specific questions about these formulas?','General',1,NULL,'2026-04-07 05:56:26'),(50,7,'hi','Hello. How can I help you today. Do you need help with a subject or a question. I am here to assist you and make learning fun. What is on your mind.',NULL,1,NULL,'2026-04-09 05:20:26'),(51,7,'teach me formulas in differential equation','Let\'s learn about differential equations. A differential equation is a mathematical equation that involves a function and its derivatives. Here are some basic formulas:\n\n1. Separable Differential Equations: \nIf we have a differential equation of the form dy / dx = f(x) * g(y), we can separate the variables by dividing both sides by g(y) and multiplying by dx. This gives us: \ndy / g(y) = f(x) * dx\n\n2. First Order Linear Differential Equations: \nIf we have a differential equation of the form dy / dx + P(x) * y = Q(x), we can use an integrating factor to solve it. The integrating factor is e^(integral of P(x) dx).\n\n3. Second Order Linear Homogeneous Differential Equations: \nIf we have a differential equation of the form d ^ 2y / dx ^ 2 + P(x) * dy / dx + Q(x) * y = 0, we can try to find the roots of the characteristic equation: \nr ^ 2 + P(x) * r + Q(x) = 0\n\nIf the roots are real and distinct, the general solution is: \ny = c1 * e^(r1 * x) + c2 * e^(r2 * x)\n\nIf the roots are real and equal, the general solution is: \ny = (c1 + c2 * x) * e^(r * x)\n\nIf the roots are complex, the general solution is: \ny = e^(a * x) * (c1 * cos(b * x) + c2 * sin(b * x))\n\nDon\'t worry if these formulas seem overwhelming. With practice, you\'ll become more comfortable using them to solve differential equations. Do you have any specific questions or would you like to practice solving some problems?',NULL,1,NULL,'2026-04-09 05:21:35');
/*!40000 ALTER TABLE `ai_doubt_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ai_history`
--

DROP TABLE IF EXISTS `ai_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` int NOT NULL,
  `type` enum('homework','doubt') NOT NULL,
  `prompt` text NOT NULL,
  `response` text NOT NULL,
  `image_path` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `student_id` (`student_id`),
  CONSTRAINT `ai_history_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=57 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ai_history`
--

LOCK TABLES `ai_history` WRITE;
/*!40000 ALTER TABLE `ai_history` DISABLE KEYS */;
INSERT INTO `ai_history` VALUES (18,7,'doubt','a┬│+a┬▓=36 find a=?','Let\'s solve the equation a ^ 3 + a ^ 2 = 36 together. \n\nFirst, we notice that a ^ 3 + a ^ 2 can be factored as a ^ 2(a + 1). \n\nSo, a ^ 2(a + 1) = 36. \n\nNow, let\'s think of numbers that when squared give us a factor of 36. \n\nWe know that 6 ^ 2 = 36. \n\nWhat if a = 3, since 3 ^ 2 = 9, and 9 * (3 + 1) = 9 * 4 = 36. \n\nLet\'s check if a = 3 satisfies the equation. \n3 ^ 3 + 3 ^ 2 = 27 + 9 = 36. \n\nYes, it does. \nSo, a = 3 is one possible answer. \n\nYou did a great job asking this question, and I\'m proud of you for trying to learn. Keep it up.',NULL,'2026-01-25 18:12:06'),(19,7,'doubt','a┬│+a┬▓=36 find a=?','Let\'s solve this problem together. We have the equation a ^ 3 + a ^ 2 = 36. To find the value of a, we can try to factor out a from the left side of the equation. \n\nSo, we can write it as a ^ 2(a + 1) = 36. Now, we need to find a number that, when squared and multiplied by the number plus one, gives us 36.\n\nLet\'s think about the factors of 36. We know that 6 * 6 = 36. So, a ^ 2 could be 6 * 6, which means a could be 6, but we need to check if it works.\n\nIf a is 6, then a + 1 is 7. And 6 * 6 * 7 is not 36. So, a is not 6.\n\nLet\'s try another factor of 36. We know that 3 * 12 = 36 and 4 * 9 = 36, but also 1 * 36 = 36 and 2 * 18 = 36 and 6 * 6 = 36 and 9 * 4 = 36. And also 36 * 1 = 36. \n\nBut if we try a = 3, then a ^ 2 is 9 and a + 1 is 4. And 9 * 4 = 36. \n\nSo, the value of a that satisfies the equation a ^ 3 + a ^ 2 = 36 is a = 3. Great job on asking this question and I hope this explanation helps you understand the solution better.',NULL,'2026-01-26 02:07:03'),(20,7,'homework','Image Analysis','AI Error: 400 {\"error\":{\"message\":\"The model `llama-3.2-11b-vision-preview` has been decommissioned and is no longer supported. Please refer to https://console.groq.com/docs/deprecations for a recommendation on which model to use instead.\",\"type\":\"invalid_request_error\",\"code\":\"model_decommissioned\"}}. Please verify models in your Groq/Gemini console.','image_stored','2026-01-28 09:39:37'),(21,7,'homework','Image Analysis','AI Error: 400 {\"error\":{\"message\":\"The model `llama-3.2-11b-vision-preview` has been decommissioned and is no longer supported. Please refer to https://console.groq.com/docs/deprecations for a recommendation on which model to use instead.\",\"type\":\"invalid_request_error\",\"code\":\"model_decommissioned\"}}. Please verify models in your Groq/Gemini console.','image_stored','2026-01-28 09:40:05'),(22,7,'homework','solve','AI Error: 400 {\"error\":{\"message\":\"The model `llama-3.2-11b-vision-preview` has been decommissioned and is no longer supported. Please refer to https://console.groq.com/docs/deprecations for a recommendation on which model to use instead.\",\"type\":\"invalid_request_error\",\"code\":\"model_decommissioned\"}}. Please verify models in your Groq/Gemini console.','image_stored','2026-01-28 09:40:31'),(23,7,'doubt','a┬│+a┬▓=36 find a=?','To solve the equation a ^ 3 + a ^ 2 = 36, let\'s try to factor out a. \nWe can write the equation as a ^ 2(a + 1) = 36. \nNow we need to find a number that when squared and multiplied by the number plus one gives 36. \nWe can try different values of a to see which one works. \nFor example, if a = 3, then a ^ 2 = 9 and a + 1 = 4, so 9 * 4 = 36. \nSo a = 3 is a possible solution. Let\'s check if it\'s the only one. \nIf a = 4, then a ^ 2 = 16 and a + 1 = 5, so 16 * 5 is not 36. \nIf a = 2, then a ^ 2 = 4 and a + 1 = 3, so 4 * 3 is not 36. \nSo it seems like a = 3 is the solution. \nDoes this make sense to you? Do you want to try any other values for a?',NULL,'2026-01-28 09:41:10'),(24,7,'doubt','2+2 =5  why','I love that you\'re thinking about math and trying to understand it. However, I want to gently help you see that 2 + 2 is actually not equal to 5. When we add 2 + 2, we are counting how many things we have altogether. \n\nLet\'s count together: if I have 2 pencils and I get 2 more pencils, how many pencils do I have now? I have 4 pencils. So, 2 + 2 is actually 4, not 5. Does that make sense? Don\'t worry if it\'s a little confusing at first - math is all about practicing and learning, and you\'re doing great!',NULL,'2026-01-28 09:41:40'),(25,7,'doubt','1,2,3,10,  What is the nest number','Let\'s take a look at the numbers you have: 1, 2, 3, 10. It seems like the pattern is adding 1 to get to the next number, but then there\'s a big jump to 10. If we were following a pattern of adding 1, the next numbers would be 1, 2, 3, 4, 5, and so on. \n\nSo, if we ignore the 10 for a moment and just look at the numbers 1, 2, 3, the next number in the pattern would be 4. Does that make sense to you?',NULL,'2026-01-28 09:42:08'),(26,7,'doubt','1,2,3,10,  What is the next number from the pattern','Let\'s take a look at the pattern together. We have 1, 2, 3, 10. To find the next number, we need to see if there\'s a relationship between these numbers. \n\nOne way to approach this is by looking at the differences between each number. The difference between 1 and 2 is 1, between 2 and 3 is 1, but between 3 and 10 is 7. \n\nHowever, a more likely pattern here is that the numbers are not just increasing by a certain amount each time, but rather, it seems like the pattern might be related to the position of the number in the sequence. \n\nOne possible pattern could be that each number is the next one in a sequence where we add 1, then add 1 again, then add 7. But this doesn\'t seem very logical or consistent.\n\nA different approach would be to consider if the numbers represent something specific or if they follow a certain mathematical operation that\'s not immediately obvious.\n\nBut let\'s think about a simple and common pattern where numbers increase in a certain way. What if we were looking at a pattern that involves adding more each time, but in a specific sequence?\n\nActually, a common sequence that comes to mind, given the numbers 1, 2, 3, 10, could be that we\'re looking at the first few numbers in the sequence of numbers where each term is one more than the previous term, but then something changes.\n\nHowever, another possible explanation for the pattern 1, 2, 3, 10 could be that it\'s not a typical arithmetic sequence where you add the same number each time, but maybe something that involves a different kind of mathematical operation or perhaps even a sequence that doesn\'t follow a simple arithmetic progression.\n\nGiven the numbers, another pattern could be that we\'re looking at the sequence of numbers that are one more than the previous term, but then there\'s a jump. But without a clear rule, it\'s hard to determine the exact pattern.\n\nLet\'s think about it in a simpler way. What if the pattern is not about addition or subtraction but about something else entirely?\n\nOne pattern that comes to mind that could fit these numbers, but seems a bit unusual, would be if we were looking at a sequence where each number is related to its position in a particular way. However, the jump from 3 to 10 suggests that if there is a pattern, it might not be a straightforward one.\n\nConsidering all these possibilities, it seems like we might need more information or a clearer rule to determine the next number in the pattern with certainty. However, if I had to guess based on common sequences and trying to find a simple explanation, I would say that without a clear rule, it\'s challenging to provide a specific next number.\n\nBut let\'s try to think about it in an even simpler way. Sometimes patterns can be based on the position of the number or a simple mathematical operation that\'s applied in a sequence. \n\nIf you have more information about the pattern or if there\'s a specific rule that we\'re supposed to apply, that would be really helpful. Otherwise, we can keep trying to figure it out together. Does that make sense?',NULL,'2026-01-28 09:42:56'),(27,7,'doubt','1,2,3,10,_ What Is the  next number','That\'s a great question. Let\'s look at the pattern together. We have 1, 2, 3, 10, and we need to find the next number.\n\nFirst, let\'s see if we can find a pattern. The numbers start with 1, 2, 3, which looks like a normal counting pattern. But then it jumps to 10.\n\nOne way to think about it is to consider if there\'s a pattern in the differences between the numbers. From 1 to 2, the difference is 1. From 2 to 3, the difference is also 1. But from 3 to 10, the difference is 7.\n\nHowever, without more information about the pattern, it\'s a bit hard to be sure what the next number should be. Can you think of any rules that might apply to this sequence? Is it based on addition, subtraction, or maybe something else?\n\nIf we had to guess based on the information given, we might look for a pattern that fits the sequence. One possible pattern could be obtained by adding 1, then 1, then 7. If we follow this pattern, the next difference should be even bigger.\n\nLet\'s try to think of a different approach. What if the pattern is not just based on simple addition or subtraction? Maybe there\'s a different kind of pattern at work here.\n\nI want to encourage you to think creatively about this problem. You\'re doing a great job by even considering the pattern and looking for a solution. Keep thinking and see if you can come up with any other ideas. Do you want to take a guess or would you like another hint?',NULL,'2026-01-28 09:43:27'),(28,7,'doubt','I need full stack developement ','Hello, I\'m happy to help you with full stack development. Don\'t worry if it sounds complicated, it\'s actually pretty cool. \n\nFull stack development means you work on both the front end and back end of a website or application. The front end is what users see and interact with, like buttons, text, and images. The back end is like the brain of the operation, it\'s where all the data is stored and processed.\n\nThink of it like a restaurant. The front end is the dining area where customers sit and order food. The back end is the kitchen where the food is prepared and orders are managed.\n\nAs a full stack developer, you would work on both the front end, using languages like HTML, CSS, and JavaScript, and the back end, using languages like Python, Ruby, or PHP. You would also work with databases to store and retrieve data.\n\nIt\'s a lot to learn, but it\'s a great skill to have, and it can be really rewarding to see a project come together. If you\'re interested in learning more, we can start with the basics and work our way up. How does that sound?',NULL,'2026-02-11 05:40:34'),(32,7,'doubt','Hi explain a2+b2','Hello, I\'m happy to help you with that. So, you want to know about a2 + b2. This is a very important concept in math, and it\'s actually pretty simple.\n\na2 + b2 is a formula that means you have to square both a and b, and then add the results together. \n\nTo square a number means to multiply it by itself. So, a2 means a * a, and b2 means b * b.\n\nFor example, if a is 3 and b is 4, then a2 would be 3 * 3, which is 9, and b2 would be 4 * 4, which is 16.\n\nThen, you would add the results together, so 9 + 16 would be 25. \n\nSo, a2 + b2 would be 25 in this case. It\'s a useful formula to know, and you\'ll use it a lot in math. Do you have any questions about it, or would you like some more examples?',NULL,'2026-02-12 04:58:39'),(33,7,'doubt','1,3,5,7,9,_ what comes next','Trouble answering: 400 {\"error\":{\"message\":\"\'messages.1\' : discriminator property \'role\' has invalid value\",\"type\":\"invalid_request_error\"}}',NULL,'2026-02-12 05:10:16'),(34,7,'doubt','Hi','Trouble answering: 400 {\"error\":{\"message\":\"\'messages.1\' : discriminator property \'role\' has invalid value\",\"type\":\"invalid_request_error\"}}',NULL,'2026-02-12 05:10:37'),(35,7,'doubt','Hi','Trouble answering: 400 {\"error\":{\"message\":\"\'messages.1\' : discriminator property \'role\' has invalid value\",\"type\":\"invalid_request_error\"}}',NULL,'2026-02-12 05:11:35'),(36,7,'doubt','Hi','It\'s nice to meet you. Is there something you need help with or would you like to learn something new today? I\'m here to assist you.',NULL,'2026-02-12 05:20:28'),(37,7,'doubt','Can you please explain trigonometry formulas','Let\'s break down the basic trigonometry formulas. \n\nThere are three main ones to remember: sine, cosine, and tangent. \n\n1. Sine (sin) is equal to the opposite side over the hypotenuse.\n2. Cosine (cos) is equal to the adjacent side over the hypotenuse.\n3. Tangent (tan) is equal to the opposite side over the adjacent side.\n\nYou can use the word SOH - CAH - TOA to help you remember these formulas:\n- SOH: sin = opposite / hypotenuse - CAH: cos = adjacent / hypotenuse - TOA: tan = opposite / adjacent\n\nThese formulas work with right triangles, which have one 90 - degree angle. \n\nDo you have any specific questions about these formulas or would you like some examples?',NULL,'2026-02-12 05:20:45'),(38,7,'doubt','Sine','The sine function is a fundamental part of trigonometry. \n\nThe sine of an angle in a right triangle is the ratio of the length of the side opposite the angle to the length of the hypotenuse. \n\nIn other words: sin = opposite side / hypotenuse\n\nFor example, if you have a right triangle with an angle of 30 degrees, and the side opposite the 30 - degree angle is 3 inches, and the hypotenuse is 6 inches, then the sine of 30 degrees would be: \nsin 30 = 3 / 6 = 0.5\n\nSo, the sine of 30 degrees is 0.5. \n\nSome common values of sine to remember are:\n- sin 30 = 0.5 - sin 45 = 0.707 (or approximately 1 / sqrt(2) but we can say 0.707 for simplicity)\n- sin 60 = 0.866 (or approximately 0.866 for simplicity)\n- sin 90 = 1\n\nKeep in mind that sine values can range from - 1 to 1, depending on the angle.\n\nDo you have any specific questions about sine or would you like some more examples?',NULL,'2026-02-12 05:20:53'),(39,7,'doubt','Tell me about deep learning','Deep learning is a type of machine learning that uses artificial neural networks to make decisions. These networks are made up of many layers of connected nodes or neurons that work together to learn and understand data.\n\nThink of it like a big team working together. Each layer of the team looks at the data, finds patterns, and then passes that information to the next layer. This process keeps going until the network can make a decision or prediction.\n\nDeep learning is really good at things like:\n\n1. **Image recognition**: It can look at a picture and tell you what\'s in it, like a dog or a car.\n2. **Speech recognition**: It can listen to someone talking and write down what they\'re saying.\n3. **Natural language processing**: It can read and understand text, like a story or a message.\n\nThe key to deep learning is that it can learn from a lot of data, like pictures or words, and get better and better over time. It\'s like a student who practices and practices until they become an expert.\n\nSome common types of deep learning networks include:\n\n1. **Convolutional neural networks** (CNNs) - these are good at image recognition\n2. **Recurrent neural networks** (RNNs) - these are good at understanding sequences, like speech or text\n3. **Generative adversarial networks** (GANs) - these are good at creating new things, like pictures or music\n\nDeep learning is a powerful tool that\'s being used in many areas, like self - driving cars, medical diagnosis, and virtual assistants. It\'s an exciting field that\'s changing the way we live and work. Do you have any specific questions about deep learning?',NULL,'2026-02-14 03:33:02'),(40,7,'doubt','How ai related to Deep learning','AI and deep learning are closely related. In fact, deep learning is a type of AI.\n\nAI stands for Artificial Intelligence, which refers to the ability of machines to think and learn like humans. AI includes a range of techniques and approaches, such as machine learning, natural language processing, and computer vision.\n\nDeep learning is a subset of machine learning, which is a subset of AI. Deep learning uses artificial neural networks to analyze data and make decisions. These networks are designed to mimic the way the human brain works, with many layers of interconnected nodes or neurons.\n\nIn other words, AI is the broad field that encompasses many techniques and approaches, including deep learning. Deep learning is a specific technique within the AI field that uses neural networks to learn and make decisions.\n\nHere\'s a simple hierarchy to illustrate the relationship:\n\n1. AI (Artificial Intelligence) - the broad field\n2. Machine Learning - a subset of AI that involves training machines to learn from data\n3. Deep Learning - a subset of machine learning that uses neural networks to analyze data\n\nSo, all deep learning is AI, but not all AI is deep learning. Deep learning is just one of the many tools and techniques that are used in the field of AI.\n\nSome AI applications that use deep learning include:\n\n1. Virtual assistants, like Siri or Alexa\n2. Image recognition systems, like self - driving cars\n3. Natural language processing, like chatbots or language translation\n4. Predictive analytics, like forecasting stock prices or weather patterns\n\nI hope that helps clarify the relationship between AI and deep learning. Do you have any other questions?',NULL,'2026-02-14 03:33:15'),(41,7,'doubt','Hi','Hello. How can I help you today with your studies? Do you have a specific subject or topic you\'re having trouble with? I\'m here to help and explain things in a way that\'s easy to understand.',NULL,'2026-02-14 06:11:22'),(42,7,'doubt','Explain trigonometry','Trigonometry is a branch of math that deals with the relationships between the sides and angles of triangles. It\'s like being a triangle detective, trying to figure out the missing pieces of the puzzle.\n\nImagine you have a triangle with two sides and an angle between them. Trigonometry helps you find the length of the third side or the size of the other angles.\n\nThere are three main trig functions: sine, cosine, and tangent. These functions help you relate the angles to the sides of the triangle.\n\n- Sine is like a ratio that compares the side opposite the angle to the longest side of the triangle.\n- Cosine is similar, but it compares the side next to the angle to the longest side.\n- Tangent is like a ratio that compares the side opposite the angle to the side next to the angle.\n\nThese functions are important because they help us solve problems in many areas, like physics, engineering, and even video games. They can be used to calculate distances, heights, and directions.\n\nDon\'t worry if it seems a bit confusing at first. With practice, you\'ll become more comfortable using these trig functions to solve problems. Do you have any specific questions about trigonometry or would you like some examples to help make it clearer?',NULL,'2026-02-14 06:11:35'),(43,7,'doubt','Formulas','Here are some basic trigonometry formulas:\n\n1. Sine formula: sin(a) = opposite side / hypotenuse\n2. Cosine formula: cos(a) = adjacent side / hypotenuse\n3. Tangent formula: tan(a) = opposite side / adjacent side\n\nThese formulas are often remembered using the word SOH - CAH - TOA:\n\n- SOH: Sine = Opposite over Hypotenuse - CAH: Cosine = Adjacent over Hypotenuse - TOA: Tangent = Opposite over Adjacent\n\nThere are also some other important formulas:\n\n- Pythagorean identity: sin ^ 2(a) + cos ^ 2(a) = 1 - Sum and difference formulas for sine and cosine:\n  sin(a + b) = sin(a)cos(b) + cos(a)sin(b)\n  sin(a - b) = sin(a)cos(b) - cos(a)sin(b)\n  cos(a + b) = cos(a)cos(b) - sin(a)sin(b)\n  cos(a - b) = cos(a)cos(b) + sin(a)sin(b)\n\nDon\'t worry if these formulas seem overwhelming at first. With practice, you\'ll get more comfortable using them to solve problems.\n\nDo you want to practice using these formulas with some examples?',NULL,'2026-02-14 06:11:46'),(44,7,'doubt','Explain trigonometry','Trigonometry is a branch of math that deals with triangles and the relationships between their sides and angles. It\'s actually pretty simple once you get the hang of it.\n\nImagine you have a triangle with two shorter sides and a longer side called the hypotenuse. Trigonometry helps you figure out the lengths of the sides and the size of the angles.\n\nThere are three main things to know in trigonometry: sine, cosine, and tangent. These are like special tools that help you solve problems.\n\nSine is the ratio of the length of the side opposite an angle to the length of the hypotenuse.\nCosine is the ratio of the length of the side next to an angle to the length of the hypotenuse.\nTangent is the ratio of the length of the side opposite an angle to the length of the side next to the angle.\n\nThese tools can be used to solve all sorts of problems, from finding the height of a building to navigating with a map and compass.\n\nDon\'t worry if it seems a bit confusing at first. With practice, you\'ll get better and better at using these tools to solve problems. Do you have any specific questions about trigonometry or would you like some examples to help you understand it better?',NULL,'2026-02-20 03:37:49'),(45,7,'doubt','Formulas','Here are some basic trigonometry formulas:\n\n1. Sine formula: sin = opposite side / hypotenuse\n2. Cosine formula: cos = adjacent side / hypotenuse\n3. Tangent formula: tan = opposite side / adjacent side\n\nThese three formulas are often remembered using the sentence \"sohcahtoa\" which stands for:\nSine = Opposite over Hypotenuse\nCosine = Adjacent over Hypotenuse\nTangent = Opposite over Adjacent\n\nThere are also some other important formulas:\n\n4. Pythagorean theorem: a ^ 2 + b ^ 2 = c ^ 2 (where a and b are the lengths of the shorter sides and c is the length of the hypotenuse)\n5. Sin(a) / a = cos(a) and cos(a) / a = sin(a) (these are just rearrangements of the first three formulas)\n\nSome other important formulas are:\n6. sin(a + b) = sin(a)cos(b) + cos(a)sin(b)\n7. cos(a + b) = cos(a)cos(b) - sin(a)sin(b)\n8. tan(a + b) = (tan(a) + tan(b)) / (1 - tan(a)tan(b))\n\nDon\'t worry if these formulas seem overwhelming at first. Just practice using them and you\'ll get the hang of it. Do you have any specific questions about these formulas or would you like some examples to help you understand them better?',NULL,'2026-02-20 03:37:57'),(46,7,'doubt','Explain trigonometry','Trigonometry is a branch of math that deals with the relationships between the sides and angles of triangles. It\'s actually pretty simple once you get the hang of it.\n\nImagine you have a triangle with two shorter sides and a longer side opposite a big angle. The shorter sides are like the legs of the triangle, and the longer side is like the hypotenuse.\n\nThere are three main concepts in trigonometry: sine, cosine, and tangent. These are like special tools that help you figure out the relationships between the angles and sides.\n\n- Sine is like a ratio that helps you find the length of the side opposite an angle.\n- Cosine is like a ratio that helps you find the length of the side next to an angle.\n- Tangent is like a ratio that helps you compare the side opposite an angle to the side next to it.\n\nYou can use these tools to solve problems involving triangles, like finding the height of a building or the distance to a landmark. It\'s actually really useful in real life.\n\nFor example, if you know the length of one side of a triangle and one of the angles, you can use trigonometry to figure out the lengths of the other sides and the other angles.\n\nDon\'t worry if it seems a bit confusing at first. With practice, you\'ll get the hang of it and be solving trig problems like a pro. Do you have any specific questions about trigonometry that I can help you with?',NULL,'2026-02-20 03:58:04'),(47,7,'doubt','Formulas','Here are the main trigonometry formulas:\n\n1. Sine formula: sin(angle) = opposite side / hypotenuse\n2. Cosine formula: cos(angle) = adjacent side / hypotenuse\n3. Tangent formula: tan(angle) = opposite side / adjacent side\n\nThese formulas are often shortened to:\n\nsin = o / h\ncos = a / h\ntan = o / a\n\nWhere:\no = opposite side\na = adjacent side\nh = hypotenuse\n\nYou can also use these formulas to find the lengths of the sides of a triangle if you know one of the angles and one of the sides.\n\nThere are also some other important formulas, such as:\n\n1. **Pythagorean theorem**: a ^ 2 + b ^ 2 = c ^ 2\nwhere a and b are the lengths of the two shorter sides, and c is the length of the hypotenuse\n\n1. **SOHCAHTOA**: this is a mnemonic device that helps you remember the trig formulas\nSine = Opposite over Hypotenuse\nCosine = Adjacent over Hypotenuse\nTangent = Opposite over Adjacent\n\nThese formulas are the building blocks of trigonometry, and once you understand them, you can start solving all sorts of problems. Do you have any specific questions about these formulas?',NULL,'2026-02-20 03:58:10'),(48,7,'doubt','Explain trigonometry','Trigonometry is a branch of math that deals with triangles and the relationships between their sides and angles. It\'s used to figure out things like how long the sides of a triangle are, and how big the angles are.\n\nImagine you\'re standing in front of a right triangle, which has one 90 degree angle. Trigonometry helps you understand the connections between the lengths of the sides and the sizes of the angles.\n\nThere are three main parts to trigonometry: sine, cosine, and tangent. These are like recipes that help you calculate the lengths of the sides and the sizes of the angles.\n\n- Sine is the ratio of the length of the side opposite the angle to the length of the longest side.\n- Cosine is the ratio of the length of the side next to the angle to the length of the longest side.\n- Tangent is the ratio of the length of the side opposite the angle to the length of the side next to the angle.\n\nFor example, if you know the length of two sides of a right triangle, you can use these recipes to find the length of the third side, or to find the size of one of the angles.\n\nTrigonometry is used in all sorts of real life situations, like building design, physics, and navigation. It might seem complicated at first, but with practice, you can get really good at using these recipes to solve problems. Do you have any specific questions about trigonometry?',NULL,'2026-02-21 04:12:49'),(49,7,'doubt','Explain formulas','Formulas are like recipes that help you solve problems in math and science. They\'re usually written as a series of numbers and symbols that you can plug values into to get an answer.\n\nThink of a formula like a box where you put in some information, turn a handle, and out comes the answer. Formulas can be simple or complicated, but they all follow the same basic idea: you put in some values, follow the steps, and get a result.\n\nFor example, the formula for the area of a rectangle is length times width. You can write this as A = l * w, where A is the area, l is the length, and w is the width. If you know the length and width of a rectangle, you can plug those values into the formula to find the area.\n\nFormulas can be used for all sorts of things, like calculating speed, distance, or temperature. They\'re like shortcuts that help you solve problems quickly and easily.\n\nSome common formulas include:\n\n- Area of a circle: A = 3.14 * r^2 - Speed: speed = distance / time - Distance: distance = speed * time\n\nThese are just a few examples, but there are many more formulas out there. The key is to understand what the formula is telling you, and to plug in the right values to get the answer you need.\n\nDon\'t worry if formulas seem confusing at first. With practice, you\'ll get better at using them to solve problems. And remember, formulas are like tools that can help you figure out answers to all sorts of questions. Do you have any specific questions about formulas?',NULL,'2026-02-21 04:13:01'),(50,7,'doubt','Hi','It\'s nice to meet you. Is there something you need help with or want to learn about? Maybe a specific subject like math, science, or reading? I\'m here to assist you.',NULL,'2026-03-09 04:20:58'),(51,7,'homework','solve the 1st question','AI Error: 400 {\"error\":{\"message\":\"The model `llama-3.2-11b-vision-preview` has been decommissioned and is no longer supported. Please refer to https://console.groq.com/docs/deprecations for a recommendation on which model to use instead.\",\"type\":\"invalid_request_error\",\"code\":\"model_decommissioned\"}}. Please verify models in your Groq/Gemini console.','image_stored','2026-04-07 05:55:46'),(52,7,'doubt','Give the trignometry formulas','Here are some basic trigonometry formulas:\n\n1. Sin A = Opposite side / Hypotenuse\n2. Cos A = Adjacent side / Hypotenuse\n3. Tan A = Opposite side / Adjacent side\n\nThese are the main ones. There are also some formulas that help you find the angles:\n\n1. Sin A / Cos A = Tan A\n2. Cos A / Sin A = Cot A\n3. Tan A * Cot A = 1\n\nAnd some formulas that help you find the sides:\n\n1. Sin (A + B) = Sin A * Cos B + Cos A * Sin B\n2. Sin (A - B) = Sin A * Cos B - Cos A * Sin B\n3. Cos (A + B) = Cos A * Cos B - Sin A * Sin B\n4. Cos (A - B) = Cos A * Cos B + Sin A * Sin B\n\nDon\'t worry if it seems a lot, just practice and you will get the hang of it. Do you have any specific questions about these formulas?',NULL,'2026-04-07 05:56:26'),(53,7,'homework','solve 1 question ','AI Error: 400 {\"error\":{\"message\":\"The model `llama-3.2-11b-vision-preview` has been decommissioned and is no longer supported. Please refer to https://console.groq.com/docs/deprecations for a recommendation on which model to use instead.\",\"type\":\"invalid_request_error\",\"code\":\"model_decommissioned\"}}. Please verify models in your Groq/Gemini console.','image_stored','2026-04-09 04:59:36'),(54,7,'homework','solve','AI Error: 404 {\"error\":{\"message\":\"The model `llama-3.2-11b-vision` does not exist or you do not have access to it.\",\"type\":\"invalid_request_error\",\"code\":\"model_not_found\"}}. Please verify models in your Groq/Gemini console.','image_stored','2026-04-09 05:20:03'),(55,7,'doubt','hi','Hello. How can I help you today. Do you need help with a subject or a question. I am here to assist you and make learning fun. What is on your mind.',NULL,'2026-04-09 05:20:26'),(56,7,'doubt','teach me formulas in differential equation','Let\'s learn about differential equations. A differential equation is a mathematical equation that involves a function and its derivatives. Here are some basic formulas:\n\n1. Separable Differential Equations: \nIf we have a differential equation of the form dy / dx = f(x) * g(y), we can separate the variables by dividing both sides by g(y) and multiplying by dx. This gives us: \ndy / g(y) = f(x) * dx\n\n2. First Order Linear Differential Equations: \nIf we have a differential equation of the form dy / dx + P(x) * y = Q(x), we can use an integrating factor to solve it. The integrating factor is e^(integral of P(x) dx).\n\n3. Second Order Linear Homogeneous Differential Equations: \nIf we have a differential equation of the form d ^ 2y / dx ^ 2 + P(x) * dy / dx + Q(x) * y = 0, we can try to find the roots of the characteristic equation: \nr ^ 2 + P(x) * r + Q(x) = 0\n\nIf the roots are real and distinct, the general solution is: \ny = c1 * e^(r1 * x) + c2 * e^(r2 * x)\n\nIf the roots are real and equal, the general solution is: \ny = (c1 + c2 * x) * e^(r * x)\n\nIf the roots are complex, the general solution is: \ny = e^(a * x) * (c1 * cos(b * x) + c2 * sin(b * x))\n\nDon\'t worry if these formulas seem overwhelming. With practice, you\'ll become more comfortable using them to solve differential equations. Do you have any specific questions or would you like to practice solving some problems?',NULL,'2026-04-09 05:21:35');
/*!40000 ALTER TABLE `ai_history` ENABLE KEYS */;
UNLOCK TABLES;

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
  `section_id` int DEFAULT NULL,
  `scheduled_at` datetime DEFAULT NULL,
  `attachment_url` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_announcement_user` (`created_by`),
  CONSTRAINT `fk_announcement_user` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `announcements`
--

LOCK TABLES `announcements` WRITE;
/*!40000 ALTER TABLE `announcements` DISABLE KEYS */;
INSERT INTO `announcements` VALUES (1,'Circular for Holiday','Tomorrow is declared a holiday due to second Saturday.',3,'teacher','2025-12-30 07:45:29',NULL,NULL,NULL),(2,'Homework','Complete math activity book pages 30 and 31.',3,'teacher','2025-12-30 07:45:35',NULL,NULL,NULL),(3,'Exam Notice','Unit test will be conducted on Friday.',6,'teacher','2025-12-30 08:21:33',NULL,NULL,NULL),(4,'Exam Notice','Unit test will be conducted on Friday.',6,'teacher','2025-12-30 08:28:11',NULL,NULL,NULL),(5,'Unit Test Reminder','Unit test starts from Monday. Be prepared.',6,'teacher','2026-01-06 05:00:33',NULL,NULL,NULL),(6,'School Announcement','You are cordially invited to our 26th January Republic Day celebration, which will take place until 12pm, followed by dismissal.',6,'teacher','2026-01-22 06:07:58',NULL,NULL,NULL),(7,'School Announcement','Attention students: please note that the math exam is approaching quickly. We encourage you to prepare thoroughly and manage your time effectively to achieve the best results. If you have any questions or concerns, don\'t hesitate to reach out to your teachers. Good luck!',6,'teacher','2026-01-23 03:12:01',NULL,NULL,NULL),(8,'multiplication exam','10questions 20marks',6,'teacher','2026-01-23 06:11:24',NULL,NULL,NULL),(9,'School Announcement','Upcoming Multiplication Exam: \nThis week, students will take a 10-question multiplication exam worth 20 marks. We are confident in their preparation and look forward to seeing their progress. If you have any questions, please don\'t hesitate to reach out to the teachers.',6,'teacher','2026-01-23 06:15:13',NULL,NULL,NULL),(10,'homework','Those who completed the work submit  tomorrow',6,'teacher','2026-01-27 04:33:11',NULL,NULL,NULL),(11,'School Announcement','≡ƒôó Important Reminder: Tomorrow is a holiday ≡ƒùô∩╕Å. We wish everyone a wonderful break and look forward to seeing you upon our return ≡ƒô¥.',6,'teacher','2026-01-28 09:48:42',NULL,NULL,NULL),(12,'School Announcement','≡ƒôó Important Announcement: \nWe are excited to announce that tomorrow will be a holiday as we embark on a trip to Mangalagiri Temple ≡ƒùô∩╕Å. Please note the following rules: \n≡ƒô¥ Students are expected to follow school guidelines and instructions during the trip.',6,'teacher','2026-01-31 13:52:02',NULL,NULL,NULL),(13,'hello','hi students',6,'teacher','2026-02-06 09:50:40',NULL,NULL,NULL),(14,'painting competition ','≡ƒôó Important School Notification: \nWe would like to inform all students, parents, and staff that a scheduled event will take place from 1:00 pm to 3:00 pm ≡ƒùô∩╕Å. Please make sure to mark your calendars accordingly and arrive on time. For more information and details, please refer to the official school website or contact the administration office ≡ƒô¥.',8,'admin','2026-02-08 05:35:55',NULL,NULL,NULL),(15,'Parents teachers meeting ','≡ƒôó Important School Notification: \nWe would like to inform all students and staff that a scheduled event will take place from 2:30 pm to 4:00 pm ≡ƒùô∩╕Å. Please make sure to mark your calendars and arrive on time. For more information and details, please refer to the official school bulletin ≡ƒô¥. If you have any questions or concerns, do not hesitate to reach out to the administration.',8,'admin','2026-02-08 05:37:20',NULL,NULL,NULL),(16,'Music event ','≡ƒôó Important School Notification: Celebration Announcement ≡ƒùô∩╕Å\n\nWe are pleased to announce that our school will be hosting a celebration in recognition of our students\' achievements and milestones. The event will take place on [Date] at [Time] and will feature various activities, performances, and awards ≡ƒô¥.\n\nAll students, parents, and staff are cordially invited to attend and participate in this special occasion. We believe that this celebration will not only acknowledge the hard work and dedication of our students but also foster a sense of community and school spirit.\n\nFurther details regarding the celebration, including the schedule and program, will be shared in the coming days. In the meantime, please mark your calendars ≡ƒùô∩╕Å and join us in honoring the accomplishments of our students.\n\nIf you have any questions or require additional information, please do not hesitate to contact us. We look forward to seeing you at the celebration! ≡ƒô¥',8,'admin','2026-02-08 06:14:31',NULL,NULL,NULL),(17,'hello','≡ƒôó Important Examination Notification: \nThe NPTEL exam is scheduled to take place tomorrow ≡ƒùô∩╕Å. All students are expected to be prepared and present at the designated time. Please review your notes and materials ≡ƒô¥ to ensure you are adequately prepared for the examination. If you have any questions or concerns, please do not hesitate to reach out to the administration.',8,'admin','2026-02-08 10:36:51',NULL,NULL,NULL),(18,'School Announcement','≡ƒôó Important Exam Announcement ≡ƒùô∩╕Å\nWe are approaching our exam on Chapter 3 formulas, worth 20 marks. ≡ƒô¥ Please review the relevant material to ensure you are well-prepared for the assessment. If you have any questions or concerns, don\'t hesitate to reach out to your instructor.',6,'teacher','2026-02-10 03:38:39',NULL,NULL,NULL),(19,'School Announcement','≡ƒôó Important Math Reminder: As we approach our trigonometry unit, please take a few minutes to review all relevant formulas ≡ƒô¥. This will help ensure a strong foundation for upcoming lessons ≡ƒùô∩╕Å.',6,'teacher','2026-02-11 03:33:52',NULL,NULL,NULL),(20,'holiday ','≡ƒôó Important School Notification: \nDue to the recent floods, the school administration has made the following adjustments to ensure the safety and well - being of our students and staff. ≡ƒùô∩╕Å The school will be closed until further notice, and all academic activities will be suspended during this period. \nStudents and parents are advised to monitor the school\'s website and social media channels for updates on the reopening date and any additional instructions. ≡ƒô¥ Please note that all assignments and deadlines will be adjusted accordingly, and further information will be provided once the school resumes operations. \nWe appreciate your understanding and cooperation during this time, and we look forward to resuming our academic activities as soon as possible.',8,'admin','2026-02-21 04:18:50',NULL,NULL,NULL),(21,'exam','tomarrow there is slip test for your section',6,'teacher','2026-04-16 04:59:34',1,NULL,NULL);
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
  `status` enum('present','absent','late','holiday') DEFAULT 'present',
  `marked_by` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_attendance` (`student_id`,`date`),
  KEY `fk_attendance_teacher` (`marked_by`),
  CONSTRAINT `fk_attendance_student` FOREIGN KEY (`student_id`) REFERENCES `students` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_attendance_teacher` FOREIGN KEY (`marked_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=194 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attendance`
--

LOCK TABLES `attendance` WRITE;
/*!40000 ALTER TABLE `attendance` DISABLE KEYS */;
INSERT INTO `attendance` VALUES (1,3,'2025-12-30','present',6,'2025-12-30 08:39:48'),(12,7,'2025-12-01','present',6,'2025-12-31 08:52:08'),(13,7,'2025-12-02','present',6,'2025-12-31 08:52:08'),(14,7,'2025-12-03','present',6,'2025-12-31 08:52:08'),(15,7,'2025-12-04','absent',6,'2025-12-31 08:52:08'),(16,7,'2025-12-05','present',6,'2025-12-31 08:52:08'),(17,7,'2025-12-06','holiday',6,'2025-12-31 08:52:08'),(18,7,'2025-12-07','present',6,'2025-12-31 08:52:08'),(19,7,'2025-12-08','present',6,'2025-12-31 08:52:08'),(20,7,'2025-12-09','absent',6,'2025-12-31 08:52:08'),(21,7,'2025-12-10','present',6,'2025-12-31 08:52:08'),(22,7,'2026-01-05','present',6,'2026-01-02 15:52:07'),(23,3,'2026-01-05','absent',6,'2026-01-02 15:52:07'),(24,7,'2026-01-02','present',6,'2026-01-02 16:03:41'),(25,3,'2026-01-02','present',6,'2026-01-02 16:03:41'),(34,3,'2026-01-04','absent',6,'2026-01-04 10:20:41'),(35,7,'2026-01-04','present',6,'2026-01-04 10:20:41'),(40,7,'2026-01-07','absent',6,'2026-01-07 10:12:56'),(41,3,'2026-01-07','absent',6,'2026-01-07 10:12:56'),(42,7,'2026-01-10','present',6,'2026-01-10 04:32:40'),(43,3,'2026-01-10','present',6,'2026-01-10 04:32:40'),(48,7,'2026-01-09','absent',6,'2026-01-10 04:38:14'),(49,3,'2026-01-09','present',6,'2026-01-10 04:38:14'),(52,3,'2026-01-08','present',6,'2026-01-10 04:40:31'),(53,7,'2026-01-08','present',6,'2026-01-10 04:40:31'),(54,7,'2026-01-11','absent',6,'2026-01-11 03:24:30'),(55,3,'2026-01-11','absent',6,'2026-01-11 03:24:30'),(56,7,'2026-01-22','absent',6,'2026-01-22 05:34:09'),(57,3,'2026-01-22','present',6,'2026-01-22 05:34:09'),(58,3,'2026-01-21','present',6,'2026-01-22 05:35:29'),(59,7,'2026-01-21','absent',6,'2026-01-22 05:35:29'),(60,7,'2026-01-20','present',6,'2026-01-23 06:39:56'),(61,3,'2026-01-20','present',6,'2026-01-23 06:39:56'),(64,7,'2026-01-24','present',6,'2026-01-24 03:03:26'),(65,3,'2026-01-24','present',6,'2026-01-24 03:03:26'),(66,7,'2026-01-27','absent',6,'2026-01-27 03:57:39'),(67,3,'2026-01-27','present',6,'2026-01-27 03:57:39'),(68,3,'2026-01-26','present',6,'2026-01-27 04:00:38'),(69,7,'2026-01-26','present',6,'2026-01-27 04:00:38'),(76,3,'2026-01-25','holiday',6,'2026-01-27 04:02:11'),(77,7,'2026-01-25','holiday',6,'2026-01-27 04:02:11'),(80,7,'2026-01-23','holiday',6,'2026-01-27 05:10:19'),(81,3,'2026-01-23','holiday',6,'2026-01-27 05:10:19'),(84,7,'2026-01-19','present',6,'2026-01-27 05:11:18'),(85,3,'2026-01-19','present',6,'2026-01-27 05:11:18'),(88,3,'2026-01-30','present',6,'2026-01-30 06:27:02'),(89,7,'2026-01-30','absent',6,'2026-01-30 06:27:02'),(90,3,'2026-01-31','present',6,'2026-01-31 06:15:26'),(91,7,'2026-01-31','present',6,'2026-01-31 06:15:26'),(92,7,'2026-02-03','present',6,'2026-02-03 09:44:18'),(93,3,'2026-02-03','absent',6,'2026-02-03 09:44:18'),(96,3,'2026-02-08','absent',6,'2026-02-08 10:28:57'),(97,7,'2026-02-08','absent',6,'2026-02-08 10:28:57'),(100,7,'2026-02-17','present',6,'2026-02-17 09:17:38'),(101,3,'2026-02-17','present',6,'2026-02-17 09:17:39'),(102,3,'2026-02-16','holiday',6,'2026-02-17 09:18:09'),(103,7,'2026-02-16','holiday',6,'2026-02-17 09:18:09'),(104,7,'2026-02-21','present',6,'2026-02-21 03:34:23'),(105,3,'2026-02-21','present',6,'2026-02-21 03:34:24'),(106,7,'2026-02-24','present',6,'2026-02-24 08:46:34'),(107,3,'2026-02-24','present',6,'2026-02-24 08:46:34'),(108,3,'2026-03-09','present',6,'2026-03-09 04:57:43'),(109,7,'2026-03-09','present',6,'2026-03-09 04:57:43'),(110,7,'2026-03-07','present',6,'2026-03-09 04:57:54'),(111,3,'2026-03-07','present',6,'2026-03-09 04:57:54'),(112,3,'2026-03-11','present',6,'2026-03-11 04:37:14'),(113,7,'2026-03-11','present',6,'2026-03-11 04:37:14'),(114,7,'2026-03-10','present',6,'2026-03-11 04:37:23'),(115,3,'2026-03-10','present',6,'2026-03-11 04:37:23'),(116,3,'2026-03-14','present',6,'2026-03-14 09:24:42'),(117,7,'2026-03-14','absent',6,'2026-03-14 09:24:42'),(118,3,'2026-03-13','present',6,'2026-03-14 09:24:51'),(119,7,'2026-03-13','present',6,'2026-03-14 09:24:51'),(122,3,'2026-03-06','holiday',6,'2026-03-14 09:26:05'),(123,7,'2026-03-06','holiday',6,'2026-03-14 09:26:05'),(126,3,'2026-03-12','present',6,'2026-03-14 09:27:00'),(127,7,'2026-03-12','present',6,'2026-03-14 09:27:00'),(128,3,'2026-03-18','absent',6,'2026-03-18 05:18:22'),(129,7,'2026-03-18','absent',6,'2026-03-18 05:18:22'),(130,3,'2026-03-17','present',6,'2026-03-18 05:18:33'),(131,7,'2026-03-17','absent',6,'2026-03-18 05:18:33'),(132,3,'2026-03-16','present',6,'2026-03-18 05:18:41'),(133,7,'2026-03-16','absent',6,'2026-03-18 05:18:41'),(134,3,'2026-03-15','holiday',6,'2026-03-18 05:18:48'),(135,7,'2026-03-15','holiday',6,'2026-03-18 05:18:48'),(136,3,'2026-03-23','present',6,'2026-03-23 04:01:17'),(137,7,'2026-03-23','present',6,'2026-03-23 04:01:17'),(138,3,'2026-03-24','present',6,'2026-03-24 06:13:13'),(139,7,'2026-03-24','present',6,'2026-03-24 06:13:13'),(140,3,'2026-03-22','present',6,'2026-03-24 06:13:22'),(141,7,'2026-03-22','present',6,'2026-03-24 06:13:22'),(148,7,'2026-03-21','absent',6,'2026-03-25 04:13:47'),(149,3,'2026-03-21','present',6,'2026-03-25 04:13:47'),(150,7,'2026-03-19','absent',6,'2026-03-25 06:13:37'),(151,3,'2026-03-19','present',6,'2026-03-25 06:13:37'),(152,7,'2026-03-20','present',6,'2026-03-25 06:13:47'),(153,3,'2026-03-20','present',6,'2026-03-25 06:13:47'),(154,3,'2026-03-02','present',6,'2026-03-25 06:14:35'),(155,7,'2026-03-02','present',6,'2026-03-25 06:14:35'),(156,3,'2026-03-03','present',6,'2026-03-25 06:14:39'),(157,7,'2026-03-03','present',6,'2026-03-25 06:14:39'),(158,3,'2026-03-04','present',6,'2026-03-25 06:14:43'),(159,7,'2026-03-04','present',6,'2026-03-25 06:14:43'),(160,3,'2026-03-05','present',6,'2026-03-25 06:14:47'),(161,7,'2026-03-05','present',6,'2026-03-25 06:14:47'),(168,3,'2026-03-28','present',6,'2026-03-28 06:49:22'),(169,7,'2026-03-28','present',6,'2026-03-28 06:49:22'),(170,7,'2026-03-27','holiday',6,'2026-03-28 07:01:53'),(171,3,'2026-03-27','holiday',6,'2026-03-28 07:01:53'),(174,7,'2026-04-02','absent',6,'2026-04-02 04:45:39'),(175,3,'2026-04-02','present',6,'2026-04-02 04:45:39'),(176,3,'2026-04-01','present',6,'2026-04-02 04:45:43'),(177,7,'2026-04-01','present',6,'2026-04-02 04:45:43'),(178,7,'2026-04-05','holiday',6,'2026-04-05 15:03:34'),(179,3,'2026-04-05','holiday',6,'2026-04-05 15:03:34'),(180,3,'2026-04-06','holiday',6,'2026-04-06 04:28:25'),(181,7,'2026-04-06','holiday',6,'2026-04-06 04:28:25'),(186,7,'2026-04-09','present',6,'2026-04-09 05:27:12'),(187,3,'2026-04-09','present',6,'2026-04-09 05:27:12'),(188,3,'2026-04-16','present',6,'2026-04-16 04:52:50'),(189,7,'2026-04-16','present',6,'2026-04-16 04:52:50'),(190,7,'2026-04-15','absent',6,'2026-04-16 04:53:07'),(191,3,'2026-04-15','present',6,'2026-04-16 04:53:07'),(192,3,'2026-04-14','holiday',6,'2026-04-16 04:53:21'),(193,7,'2026-04-14','holiday',6,'2026-04-16 04:53:22');
/*!40000 ALTER TABLE `attendance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attendance_audit`
--

DROP TABLE IF EXISTS `attendance_audit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `attendance_audit` (
  `id` int NOT NULL AUTO_INCREMENT,
  `attendance_id` int NOT NULL,
  `old_status` enum('present','absent','late','holiday') DEFAULT NULL,
  `new_status` enum('present','absent','late','holiday') DEFAULT NULL,
  `changed_by` int NOT NULL,
  `changed_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `attendance_id` (`attendance_id`),
  CONSTRAINT `attendance_audit_ibfk_1` FOREIGN KEY (`attendance_id`) REFERENCES `attendance` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attendance_audit`
--

LOCK TABLES `attendance_audit` WRITE;
/*!40000 ALTER TABLE `attendance_audit` DISABLE KEYS */;
INSERT INTO `attendance_audit` VALUES (1,49,'absent','present',6,'2026-01-23 06:40:06'),(2,66,'present','absent',6,'2026-01-27 04:01:08'),(3,67,'present','absent',6,'2026-01-27 04:01:31'),(4,67,'absent','holiday',6,'2026-01-27 04:01:52'),(5,66,'absent','holiday',6,'2026-01-27 04:01:52'),(6,66,'holiday','present',6,'2026-01-27 04:02:30'),(7,67,'holiday','present',6,'2026-01-27 04:02:30'),(8,66,'present','absent',6,'2026-01-27 05:10:33'),(9,93,'present','absent',6,'2026-02-03 14:48:45'),(10,96,'present','absent',6,'2026-02-08 14:17:25'),(11,97,'present','absent',6,'2026-02-08 14:17:25'),(12,116,'absent','present',6,'2026-03-24 06:13:31'),(13,139,'absent','present',6,'2026-03-25 04:13:31'),(14,141,'absent','present',6,'2026-03-25 04:13:41'),(15,114,'absent','present',6,'2026-03-26 03:49:03'),(16,113,'absent','present',6,'2026-03-26 03:49:06'),(17,127,'absent','present',6,'2026-03-26 03:49:09'),(18,180,'present','holiday',6,'2026-04-06 04:28:48'),(19,181,'present','holiday',6,'2026-04-06 04:28:48'),(20,179,'present','holiday',6,'2026-04-06 04:29:02'),(21,178,'present','holiday',6,'2026-04-06 04:29:02');
/*!40000 ALTER TABLE `attendance_audit` ENABLE KEYS */;
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
  `is_published` tinyint(1) DEFAULT '0',
  `section_id` int DEFAULT NULL,
  `total_marks` int DEFAULT '100',
  `passing_marks` int DEFAULT '35',
  PRIMARY KEY (`id`),
  KEY `fk_exam_teacher` (`created_by`),
  KEY `fk_exams_section` (`section_id`),
  CONSTRAINT `fk_exam_teacher` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_exams_section` FOREIGN KEY (`section_id`) REFERENCES `sections` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=59 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exams`
--

LOCK TABLES `exams` WRITE;
/*!40000 ALTER TABLE `exams` DISABLE KEYS */;
INSERT INTO `exams` VALUES (1,'Mid Term','10','2025-12-20',6,'2025-12-31 05:01:39',1,NULL,100,35),(2,'Mid Term','10','2025-12-19',6,'2025-12-31 09:11:47',1,NULL,100,35),(3,'maths: fractions','Online','2026-01-22',6,'2026-01-22 10:30:27',1,1,5,1),(4,'maths: additions','Online','2026-01-22',6,'2026-01-22 10:36:45',1,1,5,1),(5,'maths: multiclations','Online','2026-01-22',6,'2026-01-22 10:41:06',1,1,5,1),(6,'sliptest','10','2026-01-23',6,'2026-01-23 02:56:30',1,1,100,35),(7,'maths: additions','Online','2026-01-23',6,'2026-01-23 03:11:11',1,1,5,1),(8,'trignometry','10','2026-01-23',6,'2026-01-23 03:34:32',1,1,100,35),(9,'maths: additions ','Online','2026-01-26',6,'2026-01-26 02:10:47',1,1,6,2),(10,'biology : nutrition','Online','2026-01-27',9,'2026-01-27 05:52:42',1,1,6,2),(11,'maths: additions','Online','2026-01-28',6,'2026-01-28 09:50:09',1,1,5,1),(12,'maths: additions','Online','2026-01-28',6,'2026-01-28 09:54:00',1,1,5,1),(13,'sciencc: nutrition','Online','2026-01-30',6,'2026-01-30 06:28:22',1,1,5,1),(14,'maths: additions','Online','2026-01-31',6,'2026-01-31 14:00:19',1,1,6,2),(15,'Maths : Linear Algebra ','Online','2026-02-10',6,'2026-02-10 03:39:50',1,1,5,1),(16,'python : loops','Online','2026-02-10',6,'2026-02-10 04:07:50',1,1,5,1),(17,'Maths: Trigonometry ','Online','2026-02-11',6,'2026-02-11 03:34:53',1,1,5,1),(18,'maths : Trigonometry ','Online','2026-02-11',6,'2026-02-11 05:47:51',1,1,5,1),(19,'Maths: Number system ','Online','2026-02-13',6,'2026-02-13 04:46:20',1,1,10,3),(20,'Science : plants ','Online','2026-02-13',6,'2026-02-13 04:53:15',1,1,5,1),(21,'science : photosynthesis ','Online','2026-02-13',6,'2026-02-13 05:38:43',1,1,5,1),(22,'science : our environment ','Online','2026-02-13',6,'2026-02-13 06:01:11',1,1,5,1),(23,'English : verbs','Online','2026-02-13',6,'2026-02-13 06:38:08',1,1,5,1),(25,'Copy Allowed Test Exam','Online','2026-02-13',8,'2026-02-13 07:27:39',1,1,10,3),(26,'English : nouns','Online','2026-02-13',6,'2026-02-13 07:42:58',1,1,10,3),(27,'Maths : ratios ','Online','2026-02-13',6,'2026-02-13 07:44:40',1,1,5,1),(28,'maths : function ','Online','2026-02-13',6,'2026-02-13 07:47:24',1,1,5,1),(29,'English : noun','Online','2026-02-13',6,'2026-02-13 07:52:11',1,1,5,1),(30,'physics : friction ','Online','2026-02-13',6,'2026-02-13 08:00:28',1,1,5,1),(31,'chemistry : chemical compounds ','Online','2026-02-13',6,'2026-02-13 08:01:35',1,1,5,1),(32,'Maths: vectors','Online','2026-02-13',6,'2026-02-13 08:06:32',1,1,5,1),(33,'English : pronoun ','Online','2026-02-13',6,'2026-02-13 08:07:30',1,1,5,1),(34,'Maths : linear Algebra ','Online','2026-02-14',6,'2026-02-14 03:14:55',1,1,10,3),(35,'science : living things ','Online','2026-02-14',6,'2026-02-14 03:15:20',1,1,5,1),(36,'Maths : linear Algebra ','Online','2026-02-18',6,'2026-02-18 03:21:38',1,1,5,1),(37,'Science : plants ','Online','2026-02-18',6,'2026-02-18 03:22:01',1,1,10,3),(38,'science : nutrition ','Online','2026-02-19',6,'2026-02-19 04:25:33',1,1,5,1),(39,'English : verbs','Online','2026-02-20',6,'2026-02-20 03:36:59',1,1,5,1),(40,'Science : plants ','Online','2026-02-20',6,'2026-02-20 03:39:19',1,1,5,1),(41,'science : nutrition ','Online','2026-02-20',6,'2026-02-20 03:40:32',1,1,5,1),(42,'English : verbs ','Online','2026-02-21',6,'2026-02-21 03:35:23',1,1,5,1),(43,'maths: linear Algebra ','Online','2026-02-21',6,'2026-02-21 04:16:47',1,1,10,3),(44,'Science : plants ','Online','2026-03-02',6,'2026-03-02 09:21:08',1,1,5,1),(45,'mathematics : trigonometry','Online','2026-03-05',6,'2026-03-05 05:16:33',1,1,5,1),(46,'maths : trigonometry ','Online','2026-03-16',6,'2026-03-16 04:40:23',1,1,10,3),(47,'eng: verbs','Online','2026-03-16',6,'2026-03-16 05:06:25',1,1,10,3),(48,'English : Tenses ','Online','2026-03-28',6,'2026-03-28 06:50:32',1,1,15,5),(49,'Maths ','10','2026-03-28',6,'2026-03-28 07:03:53',0,1,50,35),(50,'Maths: Linear Algebra ','Online','2026-04-04',6,'2026-04-04 16:33:56',1,1,10,3),(51,'English : verbs','Online','2026-04-06',6,'2026-04-06 04:52:55',1,1,10,3),(52,'Science : Nutrition ','Online','2026-04-06',6,'2026-04-06 04:53:44',1,1,10,3),(53,'English : verbs ','Online','2026-04-07',6,'2026-04-07 06:00:11',1,1,5,1),(54,'mid','10','2026-04-09',6,'2026-04-09 05:24:23',1,1,100,35),(55,'mid','10','2026-04-09',6,'2026-04-09 05:24:24',1,1,100,35),(56,'weekend','10','2026-04-09',8,'2026-04-09 08:43:33',1,1,100,35),(57,'maths: additions','Online','2026-04-09',6,'2026-04-09 08:47:04',1,1,10,3),(58,'English : Tenses ','Online','2026-04-16',6,'2026-04-16 04:32:28',1,1,10,3);
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
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fee_payments`
--

LOCK TABLES `fee_payments` WRITE;
/*!40000 ALTER TABLE `fee_payments` DISABLE KEYS */;
INSERT INTO `fee_payments` VALUES (3,3,5000.00,'2025-12-15','cash','2025-12-31 04:04:00'),(6,7,5000.00,'2025-12-14','cash','2025-12-31 09:02:46'),(10,7,4500.00,'2026-04-08','upi','2026-04-08 09:57:15');
/*!40000 ALTER TABLE `fee_payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fee_transaction_logs`
--

DROP TABLE IF EXISTS `fee_transaction_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fee_transaction_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` int NOT NULL,
  `transaction_id` varchar(100) DEFAULT NULL,
  `amount` decimal(10,2) DEFAULT NULL,
  `payment_method` enum('UPI','Card','NetBanking','Cash') DEFAULT NULL,
  `status` enum('pending','success','failed') DEFAULT 'pending',
  `provider_ref` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `transaction_id` (`transaction_id`),
  KEY `student_id` (`student_id`),
  CONSTRAINT `fee_transaction_logs_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fee_transaction_logs`
--

LOCK TABLES `fee_transaction_logs` WRITE;
/*!40000 ALTER TABLE `fee_transaction_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `fee_transaction_logs` ENABLE KEYS */;
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
-- Table structure for table `homework`
--

DROP TABLE IF EXISTS `homework`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `homework` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(100) NOT NULL,
  `description` text NOT NULL,
  `subject` varchar(50) NOT NULL,
  `section_id` int NOT NULL,
  `due_date` date NOT NULL,
  `created_by` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `is_offline` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `fk_homework_section` (`section_id`),
  KEY `fk_homework_teacher` (`created_by`),
  CONSTRAINT `fk_homework_section` FOREIGN KEY (`section_id`) REFERENCES `sections` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_homework_teacher` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `homework`
--

LOCK TABLES `homework` WRITE;
/*!40000 ALTER TABLE `homework` DISABLE KEYS */;
INSERT INTO `homework` VALUES (1,'Math Practice','Solve problems 1 to 10 from exercise 5','Mathematics',1,'2026-01-10',3,'2026-01-06 08:48:03',0),(2,'Science Worksheet','Complete chapter 3 questions','Science',1,'2026-01-12',6,'2026-01-06 08:55:24',0),(3,'chapter 2 - assignment','read all ch2','Mathematics',1,'2026-01-21',6,'2026-01-20 04:38:32',0),(4,'chapter 2 fill in the blanks','read all the formulas ','Mathematics',1,'2026-01-26',6,'2026-01-22 05:38:26',0),(7,'chapter 3','Read all the formulas ','Mathematics',1,'2026-02-18',6,'2026-02-10 03:37:49',0),(8,'Plants and Nutrition ','prepare the diagram and experiments','Biology ',1,'2026-02-12',6,'2026-02-10 03:48:43',1),(9,'Trigonometry ','All formulas ','Maths',1,'2026-02-13',6,'2026-02-11 03:34:34',0),(10,'chap2','formulas','Mathematics',1,'2026-03-26',6,'2026-03-18 05:09:42',0),(11,'Trigonometry','Solve','Mathematics',1,'2026-03-30',6,'2026-03-28 06:55:57',0),(12,'Quadratic equation ','formulas ','Mathematics',1,'2026-03-31',6,'2026-03-28 07:02:29',0),(13,'Grammer ','meaning ','hindi',1,'2026-03-30',6,'2026-03-28 09:03:00',1),(14,'chapter 2','write imp questions 5 times','Mathematics',1,'2026-04-17',6,'2026-04-16 04:54:33',0);
/*!40000 ALTER TABLE `homework` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `homework_submissions`
--

DROP TABLE IF EXISTS `homework_submissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `homework_submissions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `homework_id` int NOT NULL,
  `student_id` int NOT NULL,
  `content` text,
  `file_url` varchar(255) DEFAULT NULL,
  `marks` decimal(5,2) DEFAULT NULL,
  `feedback` text,
  `status` enum('pending','submitted','graded') DEFAULT 'submitted',
  `submitted_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `homework_id` (`homework_id`),
  KEY `student_id` (`student_id`),
  CONSTRAINT `homework_submissions_ibfk_1` FOREIGN KEY (`homework_id`) REFERENCES `homework` (`id`) ON DELETE CASCADE,
  CONSTRAINT `homework_submissions_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `homework_submissions`
--

LOCK TABLES `homework_submissions` WRITE;
/*!40000 ALTER TABLE `homework_submissions` DISABLE KEYS */;
INSERT INTO `homework_submissions` VALUES (1,9,7,'Uploaded via App','uploads/hw-1770872820451-322948505.jpg',5.00,'','graded','2026-02-12 05:07:00'),(2,4,7,'Uploaded via App','uploads/hw-1770873678636-466844739.jpg',NULL,NULL,'pending','2026-02-12 05:21:18'),(3,3,7,'Uploaded via App','uploads/hw-1770874193513-825614448.pdf',10.00,'Good','graded','2026-02-12 05:29:53'),(4,1,7,'Uploaded via App','uploads/hw-1770874889441-95840577.pdf',NULL,NULL,'pending','2026-02-12 05:41:29'),(5,3,7,'Uploaded via App','uploads/hw-1770874902004-228613322.pdf',10.00,'good','graded','2026-02-12 05:41:42'),(6,1,7,'Uploaded via App','uploads/hw-1774238270238-594229266.pdf',NULL,NULL,'pending','2026-03-23 03:57:51');
/*!40000 ALTER TABLE `homework_submissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `leaves`
--

DROP TABLE IF EXISTS `leaves`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `leaves` (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` int NOT NULL,
  `reason` text NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `status` enum('pending','approved','rejected') DEFAULT 'pending',
  `applied_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `student_id` (`student_id`),
  CONSTRAINT `leaves_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leaves`
--

LOCK TABLES `leaves` WRITE;
/*!40000 ALTER TABLE `leaves` DISABLE KEYS */;
INSERT INTO `leaves` VALUES (1,7,'not feeling well','2026-01-27','2026-01-28','rejected','2026-01-27 06:34:28'),(2,7,'not feeling weel mam','2026-01-28','2026-01-29','rejected','2026-01-28 05:09:25'),(3,7,'good morning mam \ntoday i am not feeling well to attend class','2026-01-28','2026-01-29','approved','2026-01-28 05:25:23'),(4,6,'going to Hyderabad','2026-01-28','2026-01-29','approved','2026-01-28 05:26:03'),(5,6,'going to Hyderabad','2026-01-28','2026-01-29','rejected','2026-01-28 05:26:03'),(6,7,'Good morning sir \nToday I am not able to attend 1st period ','2026-02-08','2026-02-09','approved','2026-02-08 08:21:34'),(7,6,'Good morning sir \nI am not able to attend for 2 days','2026-02-08','2026-02-10','approved','2026-02-08 08:35:06'),(8,7,'I am suffering with fever ','2026-02-08','2026-02-09','approved','2026-02-08 08:44:07'),(9,7,'don\'t want to come today ','2026-02-08','2026-02-09','approved','2026-02-08 10:24:33'),(10,8,'health issue','2026-03-11','2026-03-12','approved','2026-03-11 04:00:14'),(11,6,'health issues','2026-03-11','2026-03-12','approved','2026-03-11 04:39:29'),(12,6,'suffering with fever','2026-03-28','2026-03-29','rejected','2026-03-28 07:03:00'),(13,7,'i am suffered with fever \nso not able to attend class','2026-04-07','2026-04-08','rejected','2026-04-07 05:58:41'),(14,6,'Not feeling well','2026-04-16','2026-04-17','pending','2026-04-16 05:00:58'),(15,7,'I am not able to attend today because of fever','2026-04-16','2026-04-17','approved','2026-04-16 05:01:16'),(16,7,'I am not able to attend today because of fever','2026-04-16','2026-04-17','pending','2026-04-16 05:01:17');
/*!40000 ALTER TABLE `leaves` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mapping_audit_logs`
--

DROP TABLE IF EXISTS `mapping_audit_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mapping_audit_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `mapping_id` int DEFAULT NULL,
  `action` varchar(50) DEFAULT NULL,
  `performed_by` int DEFAULT NULL,
  `old_value` json DEFAULT NULL,
  `new_value` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mapping_audit_logs`
--

LOCK TABLES `mapping_audit_logs` WRITE;
/*!40000 ALTER TABLE `mapping_audit_logs` DISABLE KEYS */;
INSERT INTO `mapping_audit_logs` VALUES (1,1,'CREATE',8,'null','{\"role\": \"class_teacher\", \"section_id\": 5, \"teacher_id\": 9, \"subject_name\": \"science\", \"academic_year\": \"2024-25\"}','2026-01-28 03:35:01'),(2,3,'CREATE',8,'null','{\"role\": \"class_teacher\", \"section_id\": 1, \"teacher_id\": 7, \"subject_name\": \"maths\", \"academic_year\": \"2025-26\"}','2026-01-28 03:35:31'),(3,6,'CREATE',8,'null','{\"role\": \"class_teacher\", \"section_id\": 3, \"teacher_id\": 8, \"subject_name\": \"c program\", \"academic_year\": \"2025-26\"}','2026-01-28 03:36:00'),(4,7,'CREATE',8,'null','{\"role\": \"Subject Teacher\", \"section_id\": 1, \"teacher_id\": 8, \"subject_name\": \"python\", \"academic_year\": \"2024-2025\"}','2026-02-08 08:17:00'),(5,8,'CREATE',8,'null','{\"role\": \"Subject Teacher\", \"section_id\": 1, \"teacher_id\": 7, \"subject_name\": \"English\", \"academic_year\": \"2024-2025\"}','2026-02-18 04:24:35'),(6,8,'DEACTIVATE',8,'{\"id\": 8, \"role\": \"Subject Teacher\", \"is_active\": 1, \"created_at\": \"2026-02-17T22:54:35.000Z\", \"section_id\": 1, \"teacher_id\": 7, \"subject_name\": \"English\", \"academic_year\": \"2024-2025\"}','{\"is_active\": false}','2026-02-18 04:24:47'),(7,9,'CREATE',8,'null','{\"role\": \"Subject Teacher\", \"section_id\": 1, \"teacher_id\": 7, \"subject_name\": \"maths\", \"academic_year\": \"2024-2025\"}','2026-02-18 06:14:05'),(8,11,'CREATE',8,'null','{\"role\": \"Class Teacher\", \"section_id\": 1, \"teacher_id\": 7, \"subject_name\": \"physics\", \"academic_year\": \"2024-2025\"}','2026-02-21 04:18:13'),(9,12,'CREATE',8,'null','{\"role\": \"Subject Teacher\", \"section_id\": 5, \"teacher_id\": 8, \"subject_name\": \"physics\", \"academic_year\": \"2024-2025\"}','2026-02-25 06:00:21'),(10,12,'DEACTIVATE',8,'{\"id\": 12, \"role\": \"Subject Teacher\", \"is_active\": 1, \"created_at\": \"2026-02-25T00:30:21.000Z\", \"section_id\": 5, \"teacher_id\": 8, \"subject_name\": \"physics\", \"academic_year\": \"2024-2025\"}','{\"is_active\": false}','2026-02-25 06:00:29'),(11,13,'CREATE',8,'null','{\"role\": \"Subject Teacher\", \"section_id\": 1, \"teacher_id\": 8, \"subject_name\": \"physics\", \"academic_year\": \"2024-2025\"}','2026-02-25 06:01:09'),(12,14,'CREATE',8,'null','{\"role\": \"class_teacher\", \"section_id\": 6, \"teacher_id\": 8, \"subject_name\": \"English \", \"academic_year\": \"2024-25\"}','2026-03-09 06:28:21'),(13,15,'CREATE',8,'null','{\"role\": \"mentor\", \"section_id\": 6, \"teacher_id\": 8, \"subject_name\": \"Physics \", \"academic_year\": \"2024-2025\"}','2026-03-10 04:00:49'),(14,16,'CREATE',8,'null','{\"role\": \"subject_teacher\", \"section_id\": 1, \"teacher_id\": 7, \"subject_name\": \"msths\", \"academic_year\": \"2024-2025\"}','2026-03-10 06:44:10'),(15,1,'DEACTIVATE',8,'{\"id\": 1, \"role\": \"class_teacher\", \"is_active\": 1, \"created_at\": \"2026-01-27T22:05:00.000Z\", \"section_id\": 5, \"teacher_id\": 9, \"subject_name\": \"science\", \"academic_year\": \"2024-25\"}','{\"is_active\": false}','2026-03-12 08:42:50'),(16,17,'CREATE',8,'null','{\"role\": \"mentor\", \"section_id\": 5, \"teacher_id\": 8, \"subject_name\": \"python \", \"academic_year\": \"2024-2025\"}','2026-03-23 04:05:09');
/*!40000 ALTER TABLE `mapping_audit_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mass_notifications`
--

DROP TABLE IF EXISTS `mass_notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mass_notifications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `body` text NOT NULL,
  `attachment_url` varchar(512) DEFAULT NULL,
  `created_by` int NOT NULL,
  `scheduled_at` timestamp NULL DEFAULT NULL,
  `sent_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mass_notifications`
--

LOCK TABLES `mass_notifications` WRITE;
/*!40000 ALTER TABLE `mass_notifications` DISABLE KEYS */;
INSERT INTO `mass_notifications` VALUES (7,'mahotshav ','≡ƒôó Important School Notification: \nWe are pleased to announce that our annual festival will be conducted on February 5th, 6th, and 7th ≡ƒùô∩╕Å. Please mark your calendars accordingly and make necessary arrangements to participate in the festivities. Further details regarding the event schedule and activities will be shared in due course ≡ƒô¥. We look forward to your active participation and enthusiasm during the festival.',NULL,8,NULL,NULL,'2026-02-05 17:19:33','2026-02-28 00:00:00'),(8,'mahotsav','≡ƒôó Important Announcement: We are pleased to inform you that the Mahothav Fest will be taking place on ≡ƒùô∩╕Å February 5th, 6th, and 7th. ≡ƒô¥ Please mark your calendars and join us for this exciting event. Further details regarding the schedule and activities will be shared in due course.',NULL,8,NULL,NULL,'2026-02-06 10:01:26',NULL),(9,'mahotsav','≡ƒôó Important Announcement: We are pleased to inform you that the Mahothav Fest will be taking place on ≡ƒùô∩╕Å February 5th, 6th, and 7th. ≡ƒô¥ Please mark your calendars and join us for this exciting event. Further details regarding the schedule and activities will be shared in due course.',NULL,8,NULL,NULL,'2026-02-06 10:01:28',NULL),(11,'Parents Teachers Meeting ','≡ƒôó Important School Notification: \nWe would like to inform all students, parents, and staff that a scheduled event will take place from 2:00 pm to 4:00 pm ≡ƒùô∩╕Å. Please make sure to mark your calendars accordingly and arrive on time. For more information and details, please refer to the official school website or contact the administration office ≡ƒô¥.',NULL,8,NULL,NULL,'2026-02-08 04:41:43','2026-02-18 00:00:00'),(12,'Quiz competition ','≡ƒôó Important Notification: Upcoming Event ≡ƒùô∩╕Å\n\nWe are pleased to announce that a teacher will be serving as a judge for an upcoming event, and we invite all students to participate. The event is scheduled to take place from 2:00 pm to 4:00 pm ≡ƒô¥. We encourage all interested students to join us during this time and showcase their skills. Please make a note of the timings and we look forward to seeing you there.',NULL,8,NULL,NULL,'2026-02-08 04:53:43','2026-02-10 00:00:00'),(13,'Zoom meeting ','≡ƒôó Important School Notification: \nWe would like to inform all students, faculty, and staff that a scheduled event will take place from 2:00 pm to 4:00 pm ≡ƒùô∩╕Å. Please make sure to mark your calendars accordingly and arrive on time. For more information and details, please refer to the official school website or contact the administration office ≡ƒô¥.',NULL,8,NULL,NULL,'2026-02-08 05:12:19','2026-02-10 00:00:00'),(14,'painting competition ','≡ƒôó Important School Notification: \nWe would like to inform all students, parents, and staff that a scheduled event will take place from 1:00 pm to 3:00 pm ≡ƒùô∩╕Å. Please make sure to mark your calendars accordingly and arrive on time. For more information and details, please refer to the official school website or contact the administration office ≡ƒô¥.',NULL,8,NULL,NULL,'2026-02-08 05:35:54',NULL),(15,'Parents teachers meeting ','≡ƒôó Important School Notification: \nWe would like to inform all students and staff that a scheduled event will take place from 2:30 pm to 4:00 pm ≡ƒùô∩╕Å. Please make sure to mark your calendars and arrive on time. For more information and details, please refer to the official school bulletin ≡ƒô¥. If you have any questions or concerns, do not hesitate to reach out to the administration.',NULL,8,NULL,NULL,'2026-02-08 05:37:19',NULL),(16,'Zoom meeting ','≡ƒôó Important School Notification: \nWe would like to inform all students and faculty that there will be a scheduled event from 1:00 pm to 2:00 pm ≡ƒùô∩╕Å. Please make sure to mark your calendars accordingly and arrive on time. For more information, please refer to the official school bulletin ≡ƒô¥ or contact the administration office.',NULL,8,NULL,NULL,'2026-02-08 05:50:40',NULL),(17,'Zoom meeting ','≡ƒôó Important School Notification: \nWe would like to bring to your attention that a significant event is scheduled to take place at 10:00 a.m. ≡ƒùô∩╕Å. Please make sure to mark your calendars accordingly and arrive on time. For further details and updates, please refer to the official school website or contact the administration office ≡ƒô¥.',NULL,8,NULL,NULL,'2026-02-08 05:52:15',NULL),(18,'Zoom meeting ','≡ƒôó Important School Notification: \nWe would like to inform all students and faculty that a scheduled event will take place from 1:00 pm to 3:00 pm ≡ƒùô∩╕Å. Please make sure to mark your calendars accordingly and arrive on time. For more information and details, please refer to the official school announcement ≡ƒô¥.',NULL,8,NULL,NULL,'2026-02-08 06:05:47',NULL),(19,'Music event ','≡ƒôó Important School Notification: Celebration Announcement ≡ƒùô∩╕Å\n\nWe are pleased to announce that our school will be hosting a celebration in recognition of our students\' achievements and milestones. The event will take place on [Date] at [Time] and will feature various activities, performances, and awards ≡ƒô¥.\n\nAll students, parents, and staff are cordially invited to attend and participate in this special occasion. We believe that this celebration will not only acknowledge the hard work and dedication of our students but also foster a sense of community and school spirit.\n\nFurther details regarding the celebration, including the schedule and program, will be shared in the coming days. In the meantime, please mark your calendars ≡ƒùô∩╕Å and join us in honoring the accomplishments of our students.\n\nIf you have any questions or require additional information, please do not hesitate to contact us. We look forward to seeing you at the celebration! ≡ƒô¥',NULL,8,NULL,NULL,'2026-02-08 06:14:31',NULL),(20,'hello','≡ƒôó Important Examination Notification: \nThe NPTEL exam is scheduled to take place tomorrow ≡ƒùô∩╕Å. All students are expected to be prepared and present at the designated time. Please review your notes and materials ≡ƒô¥ to ensure you are adequately prepared for the examination. If you have any questions or concerns, please do not hesitate to reach out to the administration.',NULL,8,NULL,NULL,'2026-02-08 10:36:50','2026-02-17 00:00:00'),(21,'holiday ','≡ƒôó Important School Notification: \nDue to the recent floods, the school administration has made the following adjustments to ensure the safety and well - being of our students and staff. ≡ƒùô∩╕Å The school will be closed until further notice, and all academic activities will be suspended during this period. \nStudents and parents are advised to monitor the school\'s website and social media channels for updates on the reopening date and any additional instructions. ≡ƒô¥ Please note that all assignments and deadlines will be adjusted accordingly, and further information will be provided once the school resumes operations. \nWe appreciate your understanding and cooperation during this time, and we look forward to resuming our academic activities as soon as possible.',NULL,8,NULL,NULL,'2026-02-21 04:18:50',NULL),(22,'zoom','≡ƒôó Important School Notification: \nWe would like to bring to your attention that a significant event is scheduled to take place today at 4:00 p.m. ≡ƒùô∩╕Å. Please make sure to mark your calendars and be present at the designated time. For further details and any necessary documentation, please refer to the official school website or contact the administration ≡ƒô¥.',NULL,8,NULL,NULL,'2026-03-10 05:40:45',NULL),(23,'zoom meeting ','≡ƒôó Important School Notification: \nWe would like to bring to your attention that a significant event is scheduled to take place today at 4:00 pm ≡ƒùô∩╕Å. Please make sure to mark your calendars and be present at the designated time. For further details and any necessary documentation, please refer to the official school website or contact the administration ≡ƒô¥.',NULL,8,NULL,NULL,'2026-03-10 06:44:58',NULL);
/*!40000 ALTER TABLE `mass_notifications` ENABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `messages`
--

LOCK TABLES `messages` WRITE;
/*!40000 ALTER TABLE `messages` DISABLE KEYS */;
INSERT INTO `messages` VALUES (1,3,6,'student','Sir, can you explain quadratic equations?','2025-12-31 04:27:14'),(2,3,6,'teacher','Sure, I will explain it in tomorrow\'s class.','2025-12-31 04:30:07'),(3,7,6,'student','Sir, can you explain quadratic equations?','2025-12-31 10:27:47'),(4,7,6,'student','hello sir','2026-01-02 07:12:22'),(5,7,6,'teacher','sure i will explain ','2026-01-02 13:51:02'),(6,3,6,'teacher','hello','2026-01-07 10:07:56'),(7,7,6,'teacher','hey hi','2026-01-07 10:08:06'),(8,7,6,'teacher','mam','2026-01-07 10:08:08'),(9,7,6,'teacher','sir','2026-01-07 10:08:11'),(10,7,6,'student','<','2026-01-10 05:12:50'),(11,7,6,'teacher','good mng','2026-01-11 03:57:26'),(12,7,6,'student','hii','2026-01-22 05:26:27'),(13,7,9,'student','hi','2026-01-22 05:26:34'),(14,7,11,'student','hlo sir','2026-01-23 06:32:45'),(15,7,9,'teacher','hi','2026-01-27 04:36:08'),(16,7,9,'student','hello sathvika miss','2026-01-27 04:38:50'),(17,7,9,'student','can you exaplain c programming loops concepts','2026-01-27 04:39:12'),(18,7,9,'student','mam please reply','2026-01-27 04:40:02'),(19,7,9,'teacher','sure','2026-01-27 04:40:17'),(20,7,9,'student','when will you explain?','2026-01-27 04:40:32'),(21,7,9,'student','hi','2026-01-27 05:46:09'),(22,7,6,'teacher','hi','2026-01-27 05:46:13'),(23,7,9,'teacher','hi','2026-01-27 05:46:54'),(24,7,9,'student','hello','2026-01-27 05:47:02'),(25,7,9,'student','hi mam','2026-01-27 06:33:15'),(26,7,9,'student','hello mam','2026-01-27 06:33:32'),(27,7,9,'teacher','hi','2026-01-27 06:33:38'),(28,7,9,'teacher','hello','2026-01-27 06:33:45'),(29,7,6,'student','hello','2026-01-28 09:35:28'),(30,7,6,'student','hi','2026-01-28 09:35:38'),(31,7,6,'student','hello','2026-02-08 14:13:48'),(32,3,6,'teacher','hi','2026-03-28 07:01:20'),(33,7,6,'teacher','hi','2026-03-28 07:01:29'),(34,7,6,'student','hello mam','2026-04-06 04:29:22'),(35,7,6,'teacher','hi','2026-04-06 04:29:31'),(36,7,6,'student','hello mam','2026-04-07 05:49:15');
/*!40000 ALTER TABLE `messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notification_receipts`
--

DROP TABLE IF EXISTS `notification_receipts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notification_receipts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `notification_id` int NOT NULL,
  `user_id` int NOT NULL,
  `status` enum('pending','delivered','seen','failed') DEFAULT 'pending',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `notification_id` (`notification_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `notification_receipts_ibfk_1` FOREIGN KEY (`notification_id`) REFERENCES `mass_notifications` (`id`),
  CONSTRAINT `notification_receipts_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=130 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification_receipts`
--

LOCK TABLES `notification_receipts` WRITE;
/*!40000 ALTER TABLE `notification_receipts` DISABLE KEYS */;
INSERT INTO `notification_receipts` VALUES (30,7,3,'pending','2026-02-05 17:19:34'),(31,7,7,'pending','2026-02-05 17:19:34'),(32,7,10,'pending','2026-02-05 17:19:34'),(33,7,6,'pending','2026-02-05 17:19:34'),(34,7,9,'pending','2026-02-05 17:19:34'),(35,7,11,'pending','2026-02-05 17:19:34'),(36,7,12,'pending','2026-02-05 17:19:34'),(37,8,3,'pending','2026-02-06 10:01:27'),(38,8,7,'seen','2026-03-09 03:40:26'),(39,8,10,'pending','2026-02-06 10:01:27'),(40,8,6,'seen','2026-03-09 06:04:11'),(41,8,9,'pending','2026-02-06 10:01:27'),(42,8,11,'pending','2026-02-06 10:01:27'),(43,8,12,'pending','2026-02-06 10:01:27'),(44,9,3,'pending','2026-02-06 10:01:28'),(45,9,7,'seen','2026-03-09 03:40:25'),(46,9,10,'pending','2026-02-06 10:01:28'),(47,9,6,'seen','2026-03-09 06:04:08'),(48,9,9,'pending','2026-02-06 10:01:28'),(49,9,11,'pending','2026-02-06 10:01:28'),(50,9,12,'pending','2026-02-06 10:01:28'),(58,11,6,'pending','2026-02-08 04:41:44'),(59,11,9,'pending','2026-02-08 04:41:44'),(60,11,11,'pending','2026-02-08 04:41:44'),(61,11,12,'pending','2026-02-08 04:41:44'),(62,11,3,'pending','2026-02-08 04:41:44'),(63,11,7,'pending','2026-02-08 04:41:44'),(64,11,10,'pending','2026-02-08 04:41:44'),(65,12,6,'pending','2026-02-08 04:53:44'),(66,12,9,'pending','2026-02-08 04:53:44'),(67,12,11,'pending','2026-02-08 04:53:44'),(68,12,12,'pending','2026-02-08 04:53:44'),(69,12,3,'pending','2026-02-08 04:53:44'),(70,12,7,'pending','2026-02-08 04:53:44'),(71,12,10,'pending','2026-02-08 04:53:44'),(72,13,6,'pending','2026-02-08 05:12:19'),(73,13,9,'pending','2026-02-08 05:12:19'),(74,13,11,'pending','2026-02-08 05:12:19'),(75,13,12,'pending','2026-02-08 05:12:19'),(76,13,3,'pending','2026-02-08 05:12:19'),(77,13,7,'pending','2026-02-08 05:12:19'),(78,13,10,'pending','2026-02-08 05:12:19'),(79,14,3,'pending','2026-02-08 05:35:55'),(80,14,7,'seen','2026-03-09 03:40:24'),(81,14,10,'pending','2026-02-08 05:35:55'),(82,15,6,'seen','2026-03-09 06:04:12'),(83,15,9,'pending','2026-02-08 05:37:20'),(84,15,11,'pending','2026-02-08 05:37:20'),(85,15,12,'pending','2026-02-08 05:37:20'),(86,15,3,'pending','2026-02-08 05:37:20'),(87,15,7,'seen','2026-03-09 03:40:22'),(88,15,10,'pending','2026-02-08 05:37:20'),(89,16,6,'seen','2026-03-09 05:31:18'),(90,16,9,'pending','2026-02-08 05:50:41'),(91,16,11,'pending','2026-02-08 05:50:41'),(92,16,12,'pending','2026-02-08 05:50:41'),(93,17,6,'seen','2026-04-02 05:34:43'),(94,17,9,'pending','2026-02-08 05:52:15'),(95,17,11,'pending','2026-02-08 05:52:15'),(96,17,12,'pending','2026-02-08 05:52:15'),(97,18,6,'seen','2026-03-09 06:04:14'),(98,18,9,'pending','2026-02-08 06:05:47'),(99,18,11,'pending','2026-02-08 06:05:47'),(100,18,12,'pending','2026-02-08 06:05:47'),(101,19,6,'seen','2026-03-09 06:04:16'),(102,19,9,'pending','2026-02-08 06:14:32'),(103,19,11,'pending','2026-02-08 06:14:32'),(104,19,12,'pending','2026-02-08 06:14:32'),(105,19,3,'pending','2026-02-08 06:14:32'),(106,19,7,'seen','2026-03-09 03:40:20'),(107,19,10,'pending','2026-02-08 06:14:32'),(108,20,6,'pending','2026-02-08 10:36:51'),(109,20,9,'pending','2026-02-08 10:36:51'),(110,20,11,'pending','2026-02-08 10:36:51'),(111,20,12,'pending','2026-02-08 10:36:51'),(112,20,3,'pending','2026-02-08 10:36:51'),(113,20,7,'pending','2026-02-08 10:36:51'),(114,20,10,'pending','2026-02-08 10:36:51'),(115,21,6,'seen','2026-03-09 06:04:17'),(116,21,9,'pending','2026-02-21 04:18:50'),(117,21,11,'pending','2026-02-21 04:18:50'),(118,21,12,'pending','2026-02-21 04:18:50'),(119,21,3,'pending','2026-02-21 04:18:50'),(120,21,7,'seen','2026-03-09 03:40:19'),(121,21,10,'pending','2026-02-21 04:18:50'),(122,22,6,'seen','2026-04-02 05:03:33'),(123,22,9,'pending','2026-03-10 05:40:45'),(124,22,11,'pending','2026-03-10 05:40:45'),(125,22,12,'pending','2026-03-10 05:40:45'),(126,23,6,'seen','2026-04-02 05:03:29'),(127,23,9,'pending','2026-03-10 06:44:58'),(128,23,11,'pending','2026-03-10 06:44:58'),(129,23,12,'pending','2026-03-10 06:44:58');
/*!40000 ALTER TABLE `notification_receipts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `title` varchar(255) NOT NULL,
  `body` text NOT NULL,
  `type` enum('homework','attendance','announcement','general') DEFAULT 'general',
  `is_read` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `online_exam_answers`
--

DROP TABLE IF EXISTS `online_exam_answers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `online_exam_answers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `attempt_id` int NOT NULL,
  `question_id` int NOT NULL,
  `student_answer` text,
  `is_correct` tinyint(1) DEFAULT NULL,
  `marks_awarded` decimal(5,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `attempt_id` (`attempt_id`),
  KEY `question_id` (`question_id`),
  CONSTRAINT `online_exam_answers_ibfk_1` FOREIGN KEY (`attempt_id`) REFERENCES `online_exam_attempts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `online_exam_answers_ibfk_2` FOREIGN KEY (`question_id`) REFERENCES `online_exam_questions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=136 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `online_exam_answers`
--

LOCK TABLES `online_exam_answers` WRITE;
/*!40000 ALTER TABLE `online_exam_answers` DISABLE KEYS */;
INSERT INTO `online_exam_answers` VALUES (16,2,6,'3',1,1.00),(17,2,7,'5',1,1.00),(18,2,8,'9',1,1.00),(19,2,9,'5',1,1.00),(20,2,10,'10',1,1.00),(21,3,16,'3',1,1.00),(22,3,17,'8',1,1.00),(23,3,18,'7',1,1.00),(24,3,19,'0',0,0.00),(25,3,20,'9',0,0.00),(44,5,27,'Carbohydrates',1,1.00),(45,5,28,'protiens',0,0.00),(46,5,29,'Protein',1,1.00),(47,5,30,'calicium',0,0.00),(48,5,31,'To aid digestion',1,1.00),(49,5,32,'apple',1,1.00),(50,6,43,'To provide energy',1,1.00),(51,6,44,'protein \n',0,0.00),(52,6,45,'Calcium',1,1.00),(53,6,46,'digestive ',1,1.00),(54,6,47,'To stay hydrated and remove waste from the body',1,1.00),(55,7,48,'1456',0,0.00),(56,7,49,'15',0,0.00),(57,7,50,'0000',0,0.00),(58,7,51,'1050',0,0.00),(59,7,52,'gopi',0,0.00),(60,7,53,'',1,1.00),(61,8,64,'56',0,0.00),(62,8,65,'1/2',0,0.00),(63,8,66,'45',0,0.00),(64,8,67,'3/5',1,1.00),(65,8,68,'56',0,0.00),(66,9,69,'5:5',0,0.00),(67,9,70,'sine',1,1.00),(68,9,71,'right ',0,0.00),(69,9,72,'',0,0.00),(70,9,73,'cosine',0,0.00),(71,10,84,'sunlight, water and air ',1,1.00),(72,10,85,'To absorb water and nutrients',1,1.00),(73,10,86,'oxygen ',1,1.00),(74,10,87,'Leaves',1,1.00),(75,10,88,'photosynthesis ',1,1.00),(76,11,89,'To absorb light energy',1,1.00),(77,11,90,'oxygen ',1,1.00),(78,11,91,'Chloroplast',1,1.00),(79,11,92,'light, energy ',1,1.00),(80,11,93,'Glucose',1,1.00),(81,12,94,'to reduce waste ',1,1.00),(82,12,95,'burning fossil fuels',1,1.00),(83,12,96,'photosynthesis ',1,1.00),(84,12,97,'ice caps and glaciers',1,1.00),(85,12,98,'ozone ',1,1.00),(86,13,99,'big',0,0.00),(87,13,100,'ran',1,1.00),(88,13,101,'eats',1,1.00),(89,13,102,'rise',0,0.00),(90,13,103,'had finished',1,1.00),(91,18,135,'Molecule',1,1.00),(92,18,136,'',0,0.00),(93,18,137,'Oxygen',0,0.00),(94,18,138,'',0,0.00),(95,18,139,'Chemical bond',1,1.00),(96,19,140,'3',0,0.00),(97,19,141,'They can be added',1,1.00),(98,19,142,'4',0,0.00),(99,19,143,'A vector of smaller magnitude',0,0.00),(100,19,144,'4',0,0.00),(101,20,160,'Water',0,0.00),(102,20,161,'e5dyar',0,0.00),(103,20,162,'Leaves',1,1.00),(104,20,163,'',0,0.00),(105,20,164,'',0,0.00),(106,21,195,'Carbohydrates',1,1.00),(107,21,196,'protein ',0,0.00),(108,21,197,'Fruits',1,1.00),(109,21,198,'calcium ',1,1.00),(110,21,199,'Protein',1,1.00),(111,22,200,'verb',0,0.00),(112,22,201,'going',0,0.00),(113,22,202,'is',0,0.00),(114,22,203,'fh',0,0.00),(115,22,204,'writes',0,0.00),(116,23,220,'',0,0.00),(117,23,221,'yckv',0,0.00),(118,23,222,'8h',0,0.00),(119,23,223,'no',0,0.00),(120,23,224,'3:4',0,0.00),(121,24,290,'write',0,0.00),(122,24,291,'wf',0,0.00),(123,24,292,'was writing',1,1.00),(124,24,293,'qahgf',0,0.00),(125,24,294,'writes',0,0.00),(126,25,295,'7',1,1.00),(127,25,296,'4',1,1.00),(128,25,297,'12',1,1.00),(129,25,298,'10',1,1.00),(130,25,299,'18',1,1.00),(131,25,300,'3',1,1.00),(132,25,301,'9',1,1.00),(133,25,302,'7',1,1.00),(134,25,303,'5',1,1.00),(135,25,304,'',0,0.00);
/*!40000 ALTER TABLE `online_exam_answers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `online_exam_attempts`
--

DROP TABLE IF EXISTS `online_exam_attempts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `online_exam_attempts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `exam_id` int NOT NULL,
  `student_id` int NOT NULL,
  `start_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `submit_time` datetime DEFAULT NULL,
  `marks_obtained` decimal(5,2) DEFAULT NULL,
  `status` enum('started','submitted','locked') DEFAULT 'started',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_attempt` (`exam_id`,`student_id`),
  KEY `fk_oea_student` (`student_id`),
  CONSTRAINT `fk_oea_student` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `online_exam_attempts_ibfk_1` FOREIGN KEY (`exam_id`) REFERENCES `online_exams` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `online_exam_attempts`
--

LOCK TABLES `online_exam_attempts` WRITE;
/*!40000 ALTER TABLE `online_exam_attempts` DISABLE KEYS */;
INSERT INTO `online_exam_attempts` VALUES (1,1,7,'2026-01-22 16:01:07',NULL,NULL,'started'),(2,2,7,'2026-01-22 16:07:31','2026-01-22 16:07:52',5.00,'submitted'),(3,4,7,'2026-01-23 08:42:30','2026-01-23 08:42:53',3.00,'submitted'),(4,5,7,'2026-01-26 02:11:46',NULL,NULL,'started'),(5,6,7,'2026-01-27 05:53:20','2026-01-27 05:54:31',4.00,'submitted'),(6,9,7,'2026-01-30 09:37:53','2026-01-30 09:38:49',4.00,'submitted'),(7,10,7,'2026-01-31 14:01:48','2026-01-31 14:02:55',1.00,'submitted'),(8,13,7,'2026-02-11 05:44:10','2026-02-11 05:45:08',1.00,'submitted'),(9,14,7,'2026-02-11 05:48:19','2026-02-11 05:52:36',1.00,'submitted'),(10,16,7,'2026-02-13 05:11:09','2026-02-13 05:11:45',5.00,'submitted'),(11,17,7,'2026-02-13 05:45:11','2026-02-13 05:45:46',5.00,'submitted'),(12,18,7,'2026-02-13 06:01:36','2026-02-13 06:02:02',5.00,'submitted'),(13,19,7,'2026-02-13 06:38:22','2026-02-13 06:38:48',3.00,'submitted'),(14,22,7,'2026-02-13 07:44:57',NULL,NULL,'started'),(15,23,7,'2026-02-13 07:47:40',NULL,NULL,'started'),(16,20,7,'2026-02-13 07:50:39',NULL,NULL,'started'),(17,24,7,'2026-02-13 07:52:22',NULL,NULL,'started'),(18,26,7,'2026-02-13 08:01:51','2026-02-13 08:02:20',2.00,'submitted'),(19,27,7,'2026-02-13 08:10:35','2026-02-13 08:11:15',1.00,'submitted'),(20,30,7,'2026-02-14 03:33:39','2026-02-14 03:34:12',1.00,'submitted'),(21,36,7,'2026-02-20 03:58:26','2026-02-20 03:59:02',4.00,'submitted'),(22,37,7,'2026-02-21 04:13:33','2026-02-21 04:13:48',0.00,'submitted'),(23,40,7,'2026-03-05 05:16:54','2026-03-05 05:17:09',0.00,'submitted'),(24,47,7,'2026-04-07 06:01:04','2026-04-07 06:01:38',1.00,'submitted'),(25,48,7,'2026-04-09 08:47:47','2026-04-09 08:48:38',9.00,'submitted');
/*!40000 ALTER TABLE `online_exam_attempts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `online_exam_questions`
--

DROP TABLE IF EXISTS `online_exam_questions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `online_exam_questions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `exam_id` int NOT NULL,
  `question_text` text NOT NULL,
  `answer_text` text,
  `options_json` json DEFAULT NULL,
  `marks` int DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `exam_id` (`exam_id`),
  CONSTRAINT `online_exam_questions_ibfk_1` FOREIGN KEY (`exam_id`) REFERENCES `online_exams` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=315 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `online_exam_questions`
--

LOCK TABLES `online_exam_questions` WRITE;
/*!40000 ALTER TABLE `online_exam_questions` DISABLE KEYS */;
INSERT INTO `online_exam_questions` VALUES (1,1,'What is 3/4 of 24?','18',NULL,1),(2,1,'Simplify the fraction 12/16','3/4',NULL,1),(3,1,'A recipe calls for 1/4 cup of sugar, if you want to make 3 times the recipe, how much sugar will you need?','3/4 cup',NULL,1),(4,1,'A bookshelf has 5 shelves, and 3/5 of them are filled with books, how many shelves are filled with books?','3',NULL,1),(5,1,'What is 2/3 of 27?','18',NULL,1),(6,2,'2 + 1 =','3',NULL,1),(7,2,'5 + 0 =','5',NULL,1),(8,2,'7 + 2 =','9',NULL,1),(9,2,'1 + 4 =','5',NULL,1),(10,2,'9 + 1 =','10',NULL,1),(11,3,'A bookshelf has 5 shelves, and each shelf can hold 8 rows of books. If each row can hold 12 books, how many books can the bookshelf hold in total?','480',NULL,1),(12,3,'A bakery sells 250 loaves of bread per day. If they pack 10 loaves of bread in a box, how many boxes do they need per day?','25',NULL,1),(13,3,'A group of friends want to share some candy equally. If they have 48 pieces of candy and there are 8 friends, how many pieces of candy will each friend get?','6',NULL,1),(14,3,'A rectangular garden measures 12 meters by 8 meters. If a path that is 2 meters wide is built around the garden, what is the area of the path?','88',NULL,1),(15,3,'A water tank can hold 3600 liters of water. If 120 liters of water are pumped into the tank every hour, how many hours will it take to fill the tank?','30',NULL,1),(16,4,'What is 2 + 1?','3','[\"1\", \"2\", \"3\", \"4\"]',1),(17,4,'The sum of 5 and 3 is ______','8',NULL,1),(18,4,'What is 7 + 0?','7','[\"5\", \"6\", \"7\", \"8\"]',1),(19,4,'4 + 2 is equal to ______','6',NULL,1),(20,4,'What is 9 + 2?','11','[\"9\", \"10\", \"11\", \"12\"]',1),(21,5,'What is the sum of 457 and 279','736',NULL,1),(22,5,'A bookshelf has 15 books on it, if 27 more books are added, how many books are on the bookshelf now?','42',NULL,1),(23,5,'Tom has 45 pencils in his pencil case, his friend gives him 17 more pencils, how many pencils does Tom have now?','62',NULL,1),(24,5,'A basket contains 35 apples, if 19 more apples are added to it, what is the total number of apples in the basket?','54',NULL,1),(25,5,'What is the value of x in the equation 23 + x = 67','44',NULL,1),(26,5,'21+32=?','43',NULL,1),(27,6,'What is the primary source of energy for the human body?','Carbohydrates','[\"Proteins\", \"Fats\", \"Carbohydrates\", \"Vitamins\"]',1),(28,6,'The process by which the body breaks down food into smaller molecules is called ______','Digestion',NULL,1),(29,6,'Which nutrient is essential for building and repairing muscles?','Protein','[\"Carbohydrates\", \"Fats\", \"Protein\", \"Minerals\"]',1),(30,6,'Foods that are rich in ______ help to strengthen our bones and teeth','Calcium',NULL,1),(31,6,'What is the main function of fiber in our diet?','To aid digestion','[\"To provide energy\", \"To build muscles\", \"To aid digestion\", \"To fight infections\"]',1),(32,6,'a for','apple ',NULL,1),(33,7,'What is the sum of 2 + 1?','3','[\"1\", \"2\", \"3\", \"4\"]',1),(34,7,'The sum of 5 and 4 is ______','9',NULL,1),(35,7,'Which of the following is the sum of 7 and 3?','10','[\"8\", \"9\", \"10\", \"11\"]',1),(36,7,'If I have 9 pencils and I add 2 more, I have ______ pencils now','11',NULL,1),(37,7,'What is the sum of 1 + 6?','7','[\"5\", \"6\", \"7\", \"8\"]',1),(38,8,'2 + 1 = ','3',NULL,1),(39,8,'5 + 0 = ','5','[\"3\", \"5\", \"7\", \"9\"]',1),(40,8,'The sum of 7 and 2 is ______','9',NULL,1),(41,8,'8 + 4 = ','12','[\"10\", \"12\", \"14\", \"16\"]',1),(42,8,'1 + 6 = ','7','[\"5\", \"6\", \"7\", \"8\"]',1),(43,9,'What is the main function of carbohydrates in our body?','To provide energy','[\"To build muscles\", \"To provide energy\", \"To fight diseases\", \"To maintain body temperature\"]',1),(44,9,'Vitamins are a type of ______ that our body needs to stay healthy.','nutrient',NULL,1),(45,9,'Which nutrient is important for strong bones and teeth?','Calcium','[\"Protein\", \"Iron\", \"Calcium\", \"Potassium\"]',1),(46,9,'Fiber helps in the proper functioning of the ______ system.','digestive',NULL,1),(47,9,'What is the importance of drinking plenty of water?','To stay hydrated and remove waste from the body','[\"To build strong muscles\", \"To stay hydrated and remove waste from the body\", \"To improve eyesight\", \"To enhance skin beauty\"]',1),(48,10,'What is the sum of 457 and 279?','736',NULL,1),(49,10,'A bookshelf has 15 books on it. If 7 more books are added, how many books are on the bookshelf now?','22','[\"15\", \"20\", \"21\", \"22\"]',1),(50,10,'The sum of two numbers is 75. If one number is 32, the other number is ______','43',NULL,1),(51,10,'What is the sum of 945 and 117?','1062','[\"1050\", \"1060\", \"1062\", \"1070\"]',1),(52,10,'A student has 25 pencils in her pencil case. She gives 5 to her friend and then gets 8 more. The student now has ______ pencils','28',NULL,1),(53,10,'New Question','','[\"\", \"\", \"\", \"\"]',1),(54,11,'What is the determinant of a 2x2 matrix with elements a, b, c, and d?','ad - bc',NULL,1),(55,11,'Which of the following operations can be performed on two matrices of the same order?','Addition','[\"Addition\", \"Subtraction\", \"Multiplication\", \"All of the above\"]',1),(56,11,'The inverse of a matrix A is denoted by ______','A^-1',NULL,1),(57,11,'What is the purpose of the Gaussian elimination method in linear algebra?','To solve systems of linear equations','[\"To find the determinant of a matrix\", \"To solve systems of linear equations\", \"To find the inverse of a matrix\", \"To perform matrix multiplication\"]',1),(58,11,'A matrix with an equal number of rows and columns is called a ______ matrix','Square',NULL,1),(59,12,'What is the purpose of the break statement in a loop?','To exit the loop','[\"To restart the loop\", \"To exit the loop\", \"To skip the current iteration\", \"To repeat the current iteration\"]',1),(60,12,'The ______ loop is used to execute a block of code for a specified number of times.','for',NULL,1),(61,12,'What will be the output of the following code: for i in range(5): print(i)','0, 1, 2, 3, 4','[\"1, 2, 3, 4, 5\", \"0, 1, 2, 3, 4\", \"5, 4, 3, 2, 1\", \"-1, 0, 1, 2, 3\"]',1),(62,12,'The while loop will continue to execute as long as the ______ condition is true.','boolean',NULL,1),(63,12,'Which of the following loops will be used to execute a block of code if you don\'t know how many times it needs to be executed?','while loop','[\"for loop\", \"while loop\", \"do-while loop\", \"if loop\"]',1),(64,13,'In a right-angled triangle, the length of the hypotenuse is 10cm and one of the angles is 60 degrees, what is the length of the side opposite the 60 degree angle?','5*sqrt(3)',NULL,1),(65,13,'What is the value of sin(45 degrees)?','1/sqrt(2)','[\"1/2\", \"1/sqrt(2)\", \"1/3\", \"2/3\"]',1),(66,13,'The area of a triangle with two sides of length 6cm and 8cm and the included angle is 60 degrees is ______','24*sin(60 degrees) or 24*sqrt(3)/2',NULL,1),(67,13,'If tan(x) = 3/4, what is the value of sin(x)?','3/5','[\"1/2\", \"3/4\", \"3/5\", \"4/5\"]',1),(68,13,'A right-angled triangle has one angle of 30 degrees and the length of the hypotenuse is 20cm, the length of the side adjacent to the 30 degree angle is ______','10*sqrt(3)',NULL,1),(69,14,'What is the ratio of the length of the adjacent side to the length of the hypotenuse called in a right-angled triangle?','cosine',NULL,1),(70,14,'Which of the following is an example of a trigonometric function?','sine','[\"logarithm\", \"exponential\", \"sine\", \"polynomial\"]',1),(71,14,'The sine of an angle is equal to the ratio of the length of the _______ side to the length of the hypotenuse.','opposite',NULL,1),(72,14,'What is the name of the rule used to find the length of the third side of a right-angled triangle when the lengths of the other two sides are known?','Pythagoras theorem',NULL,1),(73,14,'In a right-angled triangle, which of the following trigonometric functions is defined as the ratio of the length of the opposite side to the length of the adjacent side?','tangent','[\"sine\", \"cosine\", \"tangent\", \"cosecant\"]',1),(74,15,'What is the value of the expression 2^3?','8','[\"4\", \"6\", \"8\", \"10\"]',1),(75,15,'The number 0 is a member of the set of _______ numbers.','whole',NULL,1),(76,15,'Which of the following is an example of a rational number?','3/4','[\"pi\", \"sqrt(2)\", \"3/4\", \"0.123456789\"]',1),(77,15,'The decimal expansion of the number 1/2 is _______.','0.5',NULL,1),(78,15,'What is the name of the property that states a * b = b * a?','Commutative','[\"Associative\", \"Commutative\", \"Distributive\", \"Additive\"]',1),(79,15,'What is the value of the expression 5 * 6 - 2?','28',NULL,1),(80,15,'Which of the following numbers is a rational number?','3/4','[\"pi\", \"square root of 2\", \"3/4\", \"0.123456789\"]',1),(81,15,'The number 37 is a ______ number','prime',NULL,1),(82,15,'What is the decimal expansion of the fraction 1/2?','0.5',NULL,1),(83,15,'Which of the following is an example of an irrational number?','square root of 2','[\"1/2\", \"3/4\", \"square root of 2\", \"2/3\"]',1),(84,16,'What do plants need to make food?','Sunlight, water, and air',NULL,1),(85,16,'What is the main function of roots in a plant?','To absorb water and nutrients','[\"To make food\", \"To absorb water and nutrients\", \"To release oxygen\", \"To produce flowers\"]',1),(86,16,'Plants release _______ into the air during photosynthesis.','oxygen',NULL,1),(87,16,'What part of a plant makes food through photosynthesis?','Leaves','[\"Stem\", \"Roots\", \"Leaves\", \"Flowers\"]',1),(88,16,'The process by which plants make food from sunlight is called _______','photosynthesis',NULL,1),(89,17,'What is the main function of chlorophyll in photosynthesis?','To absorb light energy','[\"To release oxygen\", \"To absorb water\", \"To absorb light energy\", \"To release carbon dioxide\"]',1),(90,17,'Plants release ______ into the air during photosynthesis.','oxygen',NULL,1),(91,17,'Which part of a plant cell is responsible for photosynthesis?','Chloroplast','[\"Mitochondria\", \"Nucleus\", \"Chloroplast\", \"Cell wall\"]',1),(92,17,'The process of photosynthesis requires ______, water, and carbon dioxide.','light energy',NULL,1),(93,17,'What is produced by plants during photosynthesis that is used by humans and animals for energy?','Glucose','[\"Starch\", \"Protein\", \"Glucose\", \"Cellulose\"]',1),(94,18,'What is the main purpose of recycling','to reduce waste',NULL,1),(95,18,'Which of the following is a major cause of air pollution','burning fossil fuels','[\"burning fossil fuels\", \"planting trees\", \"conserving water\", \"reducing noise\"]',1),(96,18,'The process of plants making their own food from sunlight is called ______','photosynthesis',NULL,1),(97,18,'What is the largest source of freshwater on Earth','ice caps and glaciers','[\"rivers\", \"lakes\", \"ice caps and glaciers\", \"atmosphere\"]',1),(98,18,'The ______ layer of the atmosphere protects us from harmful ultraviolet radiation','ozone',NULL,1),(99,19,'Which of the following is an example of a verb?','run','[\"run\", \"happy\", \"city\", \"big\"]',1),(100,19,'The dog ______ quickly across the field.','ran',NULL,1),(101,19,'What is the verb in the sentence: \'She eats breakfast every morning\'?','eats','[\"she\", \"eats\", \"breakfast\", \"morning\"]',1),(102,19,'The sun ______ in the east.','rises',NULL,1),(103,19,'Choose the correct form of the verb in the sentence: \'By the time I ______ my homework, it was midnight.\'','had finished','[\"finish\", \"finished\", \"had finished\", \"was finishing\"]',1),(104,20,'Can you copy this?','Yes',NULL,1),(105,21,'What type of noun is the word \'city\'?','Common noun','[\"Proper noun\", \"Common noun\", \"Collective noun\", \"Abstract noun\"]',1),(106,21,'The __________ of the school is very big.','playground',NULL,1),(107,21,'Which of the following is an example of a proper noun?','London','[\"city\", \"dog\", \"London\", \"happy\"]',1),(108,21,'The word \'happiness\' is an example of a noun that cannot be touched, it is a type of __________ noun.','abstract',NULL,1),(109,21,'What type of noun is the word \'team\'?','Collective noun','[\"Abstract noun\", \"Collective noun\", \"Common noun\", \"Proper noun\"]',1),(110,21,'I play cricket what is verb here','play','[]',1),(111,21,'What is a noun that refers to a person, place, or thing?','Common Noun','[\"Adjective\", \"Adverb\", \"Common Noun\", \"Verb\"]',1),(112,21,'The book is a ______','noun',NULL,1),(113,21,'Identify the noun in the sentence: The dog is very happy.','dog','[\"happy\", \"dog\", \"is\", \"very\"]',1),(114,21,'The city of Paris is a famous ______','city',NULL,1),(115,22,'A recipe for making cookies requires a ratio of 2 cups of flour to 1 cup of sugar. If you use 4 cups of flour, how many cups of sugar will you need?','2',NULL,1),(116,22,'A bookshelf has 12 books on it, and the ratio of fiction to non-fiction books is 3:1. How many fiction books are on the bookshelf?','9',NULL,1),(117,22,'What is the ratio of 6 to 8 in simplest form?','3:4','[\"1:2\", \"2:3\", \"3:4\", \"4:5\"]',1),(118,22,'A group of friends want to share some candy in a ratio of 2:2:3. If they have 21 pieces of candy, how many pieces will the person with a ratio of 3 get?','9',NULL,1),(119,22,'A bike trail is 15 km long, and the ratio of uphill to downhill is 2:5. What is the length of the downhill part of the trail?','9','[\"3\", \"6\", \"9\", \"12\"]',1),(120,23,'What is a function in mathematics?','A relation between a set of inputs and a set of possible outputs',NULL,1),(121,23,'If f(x) = 2x, what is f(3)','6','[\"4\", \"6\", \"8\", \"10\"]',1),(122,23,'The function f(x) = x + 1 is an example of a ______ function','linear',NULL,1),(123,23,'What is the domain of the function f(x) = 1/x','All real numbers except 0','[\"All real numbers\", \"All real numbers except 0\", \"All real numbers except 1\", \"All real numbers except -1\"]',1),(124,23,'If g(x) = 3x - 2, what is g(0)','-2','[\"-2\", \"0\", \"2\", \"4\"]',1),(125,24,'What is a noun?','A word that refers to a person, place, thing, or idea',NULL,1),(126,24,'Identify the type of noun in the word \'city\'','Common noun','[\"Proper noun\", \"Common noun\", \"Concrete noun\", \"Abstract noun\"]',1),(127,24,'The ______ of the school is very big','playground',NULL,1),(128,24,'Which one of the following is a proper noun?','London','[\"City\", \"London\", \"Teacher\", \"Student\"]',1),(129,24,'The word \'happiness\' is an example of a ______ noun','abstract',NULL,1),(130,25,'What is the force that opposes motion between two surfaces in contact?','Friction',NULL,1),(131,25,'Which of the following types of friction occurs when an object is moving?','Kinetic friction','[\"Static friction\", \"Kinetic friction\", \"Rolling friction\", \"Fluid friction\"]',1),(132,25,'The force of friction depends on the ______ of the surfaces in contact','roughness',NULL,1),(133,25,'What happens to the force of friction when the normal force between two surfaces increases?','It increases',NULL,1),(134,25,'Which of the following is an example of reducing friction?','Polishing surfaces','[\"Increasing the normal force\", \"Polishing surfaces\", \"Increasing the surface area\", \"Applying a lubricant and then increasing the normal force\"]',1),(135,26,'What is the smallest unit of a chemical compound?','Molecule','[\"Molecule\", \"Compound\", \"Element\", \"Mixture\"]',1),(136,26,'Water is a compound made up of hydrogen and ______','oxygen',NULL,1),(137,26,'Which of the following is an example of a chemical compound?','Water','[\"Oxygen\", \"Water\", \"Gold\", \"Air\"]',1),(138,26,'A chemical compound is formed when two or more different ______ are chemically bonded together','elements',NULL,1),(139,26,'What type of bond holds atoms together in a chemical compound?','Chemical bond','[\"Gravity\", \"Magnetic bond\", \"Chemical bond\", \"Electromagnetic bond\"]',1),(140,27,'What is the magnitude of a vector with components 3 and 4?','5',NULL,1),(141,27,'Which of the following is a property of vectors?','They can be added','[\"They can be added\", \"They can be subtracted but not added\", \"They can only be scaled\", \"They are never equal\"]',1),(142,27,'The vector with components 2 and 3 has a magnitude of ______','sqrt(13)',NULL,1),(143,27,'What is the result of adding two vectors of equal magnitude but opposite direction?','Zero vector','[\"A vector of greater magnitude\", \"A vector of smaller magnitude\", \"Zero vector\", \"A vector perpendicular to both\"]',1),(144,27,'_vectors can be represented graphically as ______ in a coordinate system','arrows',NULL,1),(145,28,'Which pronoun is used to replace the name \'Emily\' in the sentence \'Emily is going to the store, and she will buy some milk\'?','she','[\"he\", \"she\", \"it\", \"they\"]',1),(146,28,'The pronoun _______ is used to replace a singular noun.','it',NULL,1),(147,28,'Which of the following is a reflexive pronoun?','herself','[\"hers\", \"her\", \"she\", \"herself\"]',1),(148,28,'The word \'they\' is a _______ pronoun.','plural',NULL,1),(149,28,'Which of the following pronouns is used to ask a question?','who','[\"he\", \"she\", \"it\", \"who\"]',1),(150,29,'What is the order of a matrix with 4 rows and 5 columns','4x5',NULL,1),(151,29,'If A is a square matrix, which of the following is true','A','[\"A\", \"A transpose\", \"Determinant of A\", \"Inverse of A\"]',1),(152,29,'The inverse of a 2x2 matrix A with elements a, b, c, d is ______','1/(ad - bc) * [d, -b, -c, a]',NULL,1),(153,29,'What is the determinant of a 2x2 matrix with elements 1, 2, 3, 4','-2',NULL,1),(154,29,'Which of the following operations can be performed on two matrices A and B of order 2x3 and 3x2 respectively','Multiplication','[\"Addition\", \"Subtraction\", \"Multiplication\", \"Division\"]',1),(155,29,'What is the order of a matrix with 4 rows and 5 columns','4x5',NULL,1),(156,29,'If A is a square matrix, which of the following is always true?','A','[\"A\", \"A transpose\", \"Determinant of A\", \"None of the above\"]',1),(157,29,'The determinant of a 2x2 matrix ______','can be positive or negative',NULL,1),(158,29,'Which of the following operation is associative?','Matrix addition','[\"Matrix addition\", \"Matrix subtraction\", \"Matrix multiplication\", \"Matrix division\"]',1),(159,29,'If a matrix has an inverse, then the matrix is ______','non-singular',NULL,1),(160,30,'What is the basic need of all living things?','Food','[\"Water\", \"Food\", \"Shelter\", \"Air\"]',1),(161,30,'Plants make their own food through a process called __________','photosynthesis',NULL,1),(162,30,'Which part of a plant makes food?','Leaves','[\"Stem\", \"Roots\", \"Leaves\", \"Flowers\"]',1),(163,30,'The main function of the roots of a plant is to __________','absorb water and nutrients',NULL,1),(164,30,'What do we call the remains of plants and animals that lived long ago?','Fossils','[\"Rocks\", \"Fossils\", \"Minerals\", \"Soil\"]',1),(165,31,'What is the order of a matrix with 3 rows and 4 columns?','3x4',NULL,1),(166,31,'If A is a square matrix, which of the following is true','A','[\"A\", \"A transpose\", \"Determinant of A\", \"None of these\"]',1),(167,31,'The system of equations with no solutions is known as ______','inconsistent',NULL,1),(168,31,'What is the purpose of the determinant in linear algebra?','to determine if a matrix is invertible',NULL,1),(169,31,'Which operation is applied to a matrix to get its inverse','Adjoint','[\"Adjoint\", \"Transpose\", \"Inverse\", \"Determinant\"]',1),(170,32,'What do plants need to make food?','Sunlight','[\"Sunlight\", \"Water\", \"Soil\", \"Air\"]',1),(171,32,'The main function of roots in a plant is to ______','absorb water and nutrients',NULL,1),(172,32,'What is the process by which plants make food from sunlight?','Photosynthesis','[\"Respiration\", \"Photosynthesis\", \"Decomposition\", \"Fermentation\"]',1),(173,32,'Leaves are the ______ organs of a plant','food-making',NULL,1),(174,32,'Which part of a plant helps to hold it upright?','Stem','[\"Leaf\", \"Root\", \"Stem\", \"Flower\"]',1),(175,32,'What do plants need to grow','Water, sunlight and air',NULL,1),(176,32,'What is the process called when plants make their own food','Photosynthesis',NULL,1),(177,32,'What part of the plant makes food','Leaves','[\"Roots\", \"Stem\", \"Leaves\", \"Flowers\"]',1),(178,32,'The roots of a plant are used for ______','absorbing water and nutrients',NULL,1),(179,32,'Which of the following is a type of plant','Tree','[\"Animal\", \"Rock\", \"Tree\", \"Car\"]',1),(180,33,'What is the main function of carbohydrates in our body?','Energy','[\"Building muscles\", \"Energy\", \"Fixing bones\", \"Strengthening teeth\"]',1),(181,33,'Vitamins and minerals are types of ______ nutrients','micronutrients',NULL,1),(182,33,'Which nutrient is essential for strong bones and teeth?','Calcium','[\"Protein\", \"Calcium\", \"Fiber\", \"Sugar\"]',1),(183,33,'A diet that lacks ______ can lead to anemia','iron',NULL,1),(184,33,'What is the name of the process by which the body uses food to give it energy?','Metabolism','[\"Respiration\", \"Metabolism\", \"Digestion\", \"Excretion\"]',1),(185,34,'What is the past tense of the verb \'go\'?','went','[\"goes\", \"went\", \"going\", \"gone\"]',1),(186,34,'The baby ______ sleeping.','is',NULL,1),(187,34,'Which of the following verbs is in the present continuous tense?','is writing','[\"write\", \"is writing\", \"writes\", \"wrote\"]',1),(188,34,'She ______ her homework yesterday.','did',NULL,1),(189,34,'What is the present tense of the verb \'eat\'?','eat','[\"eats\", \"eat\", \"eating\", \"ate\"]',1),(190,35,'What do plants need to make food?','Sunlight, water, and carbon dioxide',NULL,1),(191,35,'What is the process called when plants make their own food?','Photosynthesis',NULL,1),(192,35,'What part of a plant helps it breathe?','Leaves','[\"Roots\", \"Stem\", \"Leaves\", \"Flowers\"]',1),(193,35,'The roots of a plant are found in the ______','soil',NULL,1),(194,35,'What is the main function of the stem in a plant?','To hold the plant upright','[\"To make food for the plant\", \"To hold the plant upright\", \"To breathe for the plant\", \"To drink water for the plant\"]',1),(195,36,'What is the main source of energy for the human body?','Carbohydrates','[\"Carbohydrates\", \"Proteins\", \"Fats\", \"Vitamins\"]',1),(196,36,'The process by which the body uses food to produce energy is called ______','metabolism',NULL,1),(197,36,'Which of the following foods is a good source of fiber?','Fruits','[\"Fruits\", \"Meat\", \"Eggs\", \"Dairy products\"]',1),(198,36,'A diet that lacks ______ can lead to weakened bones and teeth','calcium',NULL,1),(199,36,'Which nutrient is important for building and repairing muscles?','Protein','[\"Protein\", \"Carbohydrates\", \"Fats\", \"Vitamins\"]',1),(200,37,'What is the verb in the sentence \'She eats breakfast every morning\'?','eats',NULL,1),(201,37,'Choose the correct form of the verb \'go\' in the present tense for the subject \'they\'','go','[\"goes\", \"going\", \"go\", \"gone\"]',1),(202,37,'The baby _______ her first tooth when she was six months old','lost',NULL,1),(203,37,'Identify the verb in the sentence \'The dog is barking loudly\'','is barking',NULL,1),(204,37,'Which of the following is the past tense of the verb \'write\'?','wrote','[\"write\", \"writes\", \"wrote\", \"writing\"]',1),(205,38,'What is the order of a matrix with 3 rows and 4 columns?','3x4',NULL,1),(206,38,'Which of the following operations can be performed on two matrices of the same order?','Addition','[\"Addition\", \"Subtraction\", \"Multiplication\", \"All of the above\"]',1),(207,38,'The number of elements in a 2x3 matrix is ______','6',NULL,1),(208,38,'What is the result of multiplying a matrix by its inverse?','Identity matrix','[\"Zero matrix\", \"Identity matrix\", \"Diagonal matrix\", \"Null matrix\"]',1),(209,38,'A matrix with only one row is called a ______ matrix','row matrix',NULL,1),(210,38,'What is the order of a matrix with 2 rows and 3 columns?','2x3',NULL,1),(211,38,'If A is a square matrix, what is the dimension of its identity matrix?','Same as A',NULL,1),(212,38,'Which of the following operations can be performed on two matrices of the same order?','Addition','[\"Addition\", \"Subtraction\", \"Multiplication\", \"All of the above\"]',1),(213,38,'The number of elements in a 3x4 matrix is ______','12',NULL,1),(214,38,'Which of the following is a property of the identity matrix?','It does not change the matrix when multiplied','[\"It is a square matrix\", \"It has all elements as zero\", \"It does not change the matrix when multiplied\", \"It is a diagonal matrix\"]',1),(215,39,'What do plants need to make food?','Sunlight','[\"Water\", \"Sunlight\", \"Soil\", \"Air\"]',1),(216,39,'The main function of roots in a plant is to ______','absorb water and nutrients',NULL,1),(217,39,'What is the process called when plants make their own food?','Photosynthesis','[\"Respiration\", \"Photosynthesis\", \"Decomposition\", \"Fermentation\"]',1),(218,39,'Plants release ______ into the air as part of photosynthesis','oxygen',NULL,1),(219,39,'What part of a plant is responsible for making food through photosynthesis?','Leaves','[\"Stem\", \"Roots\", \"Leaves\", \"Flowers\"]',1),(220,40,'What is the value of sin(60 degrees) in a right-angled triangle with a hypotenuse of 2 and the side opposite the angle being 1?','sqrt(3)/2',NULL,1),(221,40,'If cos(x) = 3/5, what is the value of sin(x) if x is in the first quadrant?','4/5',NULL,1),(222,40,'In a right triangle, the length of the hypotenuse is 10 and one of the angles is 30 degrees. What is the length of the shorter side?','5',NULL,1),(223,40,'What is the relationship between the tangent of an angle and the sine and cosine of the angle?','tan(x) = sin(x)/cos(x)',NULL,1),(224,40,'If a right triangle has an angle of 45 degrees, what is the ratio of the lengths of the two legs?','1:1','[\"1:2\", \"2:3\", \"1:1\", \"3:4\"]',1),(225,41,'In a right-angled triangle, what is the ratio of the length of the side opposite the angle to the length of the hypotenuse called?','sine','[\"cosine\", \"sine\", \"tangent\", \"cotangent\"]',1),(226,41,'The sine of an angle in a right triangle is equal to the ratio of the length of the side ______ to the hypotenuse','opposite the angle',NULL,1),(227,41,'If tan(A) = 3/4, what is the value of sin(A) and cos(A) in a right triangle?','sin(A) = 3/5, cos(A) = 4/5',NULL,1),(228,41,'What is the value of cos(60 degrees) in a right-angled triangle?','0.5','[\"0.25\", \"0.5\", \"0.75\", \"1\"]',1),(229,41,'In a right-angled triangle, the tangent of an angle is equal to the ratio of the length of the side opposite the angle to the length of the side ______','adjacent to the angle',NULL,1),(230,41,'In a right-angled triangle, if the length of the hypotenuse is 10 cm and one of the other sides is 6 cm, what is the length of the third side?','8',NULL,1),(231,41,'What is the value of sin 30 degrees?','0.5','[\"0.2\", \"0.5\", \"0.7\", \"0.9\"]',1),(232,41,'The cosine of an angle in a right triangle is ______ when the adjacent side is 3 cm and the hypotenuse is 5 cm.','0.6',NULL,1),(233,41,'If tan x is 3/4, what is the value of sin x?','3/5','[\"3/4\", \"3/5\", \"4/5\", \"4/3\"]',1),(234,41,'In a right triangle, the sine of an angle is ______ when the length of the opposite side is 4 cm and the length of the hypotenuse is 5 cm.','0.8',NULL,1),(235,42,'Which of the following verbs is in the present perfect tense?','has eaten','[\"eat\", \"eats\", \"has eaten\", \"will eat\"]',1),(236,42,'The teacher ______ the homework to the students before the class started.','handed',NULL,1),(237,42,'Select the correct form of the verb in brackets: By the time I ______ (finish) my homework, it was midnight.','had finished','[\"finish\", \"finishes\", \"have finished\", \"had finished\"]',1),(238,42,'By next year, I ______ English for five years.','will have studied',NULL,1),(239,42,'Choose the correct verb form: If I ______ (know) the answer, I would tell you.','knew','[\"know\", \"knew\", \"have known\", \"will know\"]',1),(240,42,'Which of the following verbs is in the present perfect tense?','has written','[\"write\", \"writes\", \"has written\", \"will write\"]',1),(241,42,'The teacher ______ the homework to the students before the class ended.','handed',NULL,1),(242,42,'Identify the correct form of the verb in the sentence: By the time I ______ my homework, it was midnight.','had finished','[\"finish\", \"finishes\", \"had finished\", \"will finish\"]',1),(243,42,'The new employee ______ the company a year ago.','joined',NULL,1),(244,42,'Choose the correct verb form to complete the sentence: If I ______ more time, I would have finished the project.','had','[\"have\", \"has\", \"had\", \"will have\"]',1),(245,43,'By the time I __________ my homework, it was already midnight.','had finished','[\"finish\", \"have finished\", \"had finished\", \"was finishing\"]',1),(246,43,'If I __________ more time, I would have finished the project last week.','had',NULL,1),(247,43,'Which of the following sentences is in the present perfect tense?','I have eaten breakfast.','[\"I eat breakfast.\", \"I have eaten breakfast.\", \"I am eating breakfast.\", \"I will eat breakfast.\"]',1),(248,43,'The capital of France is ______.','Paris',NULL,1),(249,43,'By next year, I __________ English for five years.','will have been studying','[\"study\", \"will study\", \"am studying\", \"will have been studying\"]',1),(250,43,'If I ______ my homework, I will get a good grade.','do','[\"do\", \"does\", \"am doing\", \"did\"]',1),(251,43,'By the time I arrived, they ______ their project.','had finished',NULL,1),(252,43,'Which of the following sentences is in the past perfect tense?','I had eaten breakfast before I went to school.','[\"I eat breakfast before I go to school.\", \"I ate breakfast before I went to school.\", \"I have eaten breakfast before I go to school.\", \"I had eaten breakfast before I went to school.\"]',1),(253,43,'The capital of France is ______','Paris',NULL,1),(254,43,'If it ______ raining, we would go to the park.','weren\'t','[\"isn\'t\", \"aren\'t\", \"weren\'t\", \"doesn\'t\"]',1),(255,43,'By the time I ______ my homework, it was already midnight.','had finished','[\"finish\", \"have finished\", \"had finished\", \"was finishing\"]',1),(256,43,'If I ______ harder, I would have passed the exam.','had studied','[\"study\", \"studied\", \"have studied\", \"had studied\"]',1),(257,43,'The capital of France is ______.','Paris',NULL,1),(258,43,'By next year, I ______ English for five years.','will have been studying','[\"study\", \"will study\", \"am studying\", \"will have been studying\"]',1),(259,43,'They ______ their project last week, but it was not good enough.','presented',NULL,1),(260,44,'What is the order of a matrix with 3 rows and 4 columns','3x4',NULL,1),(261,44,'Which of the following operations can be performed on two matrices of the same order','Addition','[\"Addition\", \"Subtraction\", \"Multiplication\", \"All of the above\"]',1),(262,44,'The determinant of a scalar multiple of a matrix is the scalar raised to the power of ____','the order of the matrix',NULL,1),(263,44,'If A is a square matrix, then the matrix obtained by interchanging its rows into columns is called the ____ of A','transpose',NULL,1),(264,44,'Which property of matrix multiplication is not true','Commutative','[\"Commutative\", \"Associative\", \"Distributive\", \"None of the above\"]',1),(265,44,'If A is a square matrix, then the determinant of A can be found using which of the following methods','Expansion by minors','[\"Expansion by minors\", \"Cofactor expansion\", \"Eigenvalue decomposition\", \"All of the above\"]',1),(266,44,'The matrix A has an inverse if and only if the determinant of A is ______','non-zero',NULL,1),(267,44,'What is the name of the process of transforming a matrix into row echelon form','Gaussian elimination','[\"Gaussian elimination\", \"Matrix reduction\", \"Linear transformation\", \"Eigenvalue decomposition\"]',1),(268,44,'A set of vectors is said to be linearly independent if none of the vectors in the set can be expressed as a ______ of the other vectors','linear combination',NULL,1),(269,44,'The rank of a matrix is equal to the number of ______ rows or columns','linearly independent',NULL,1),(270,45,'Which verb form is used to describe an action that started in the past and continues up to the present moment?','Present perfect continuous','[\"Past simple\", \"Present perfect\", \"Present perfect continuous\", \"Past perfect continuous\"]',1),(271,45,'By the time I ______ my homework, it was already midnight.','had finished',NULL,1),(272,45,'Which of the following verbs is in the passive voice?','The play was written by Shakespeare','[\"The dog bites the man\", \"The play was written by Shakespeare\", \"The teacher teaches the students\", \"The manager manages the company\"]',1),(273,45,'The new employee ______ the project by the end of the month.','will have completed',NULL,1),(274,45,'What is the verb form of \'go\' in the sentence \'If I won the lottery, I would go on a world tour\'?','conditional','[\"imperative\", \"conditional\", \"subjunctive\", \"indicative\"]',1),(275,45,'Choose the correct verb form to complete the sentence: By next year, I ______ my driving license for five years.','will have had','[\"will have\", \"will have had\", \"have had\", \"has had\"]',1),(276,45,'The new employee ______ his job last week, but he is already making improvements.','started',NULL,1),(277,45,'Select the correct form of the verb to complete the sentence: If I ______ more time, I would learn to play the guitar.','had','[\"have\", \"has\", \"had\", \"will have\"]',1),(278,45,'By the time I arrived, they ______ their homework and were watching TV.','had finished',NULL,1),(279,45,'Which of the following verb forms is correct to complete the sentence: If it ______ yesterday, we would have gone to the beach.','had not rained','[\"rained\", \"had rained\", \"has rained\", \"had not rained\"]',1),(280,46,'What is the main source of energy for the human body?','Carbohydrates','[\"Carbohydrates\", \"Proteins\", \"Fats\", \"Vitamins\"]',1),(281,46,'A diet that lacks essential __________ can lead to health problems.','nutrients',NULL,1),(282,46,'Which nutrient is important for building and repairing muscles?','Protein','[\"Protein\", \"Carbohydrates\", \"Fats\", \"Fiber\"]',1),(283,46,'Eating a balanced diet helps to maintain a healthy __________.','weight',NULL,1),(284,46,'Which of the following food groups is a good source of fiber?','Fruits and Vegetables','[\"Dairy Products\", \"Meat and Poultry\", \"Fruits and Vegetables\", \"Grains\"]',1),(285,46,'What is the main source of energy for the human body?','Carbohydrates','[\"Carbohydrates\", \"Proteins\", \"Fats\", \"Vitamins\"]',1),(286,46,'The process by which the body uses food to build and repair tissues is called __________','anabolism',NULL,1),(287,46,'Which nutrient helps to build and repair muscles?','Protein','[\"Carbohydrates\", \"Protein\", \"Fats\", \"Vitamins\"]',1),(288,46,'A diet that lacks __________ can lead to weakened bones and teeth','calcium',NULL,1),(289,46,'What is the name of the nutrient that helps to protect the body against diseases?','Vitamin C','[\"Vitamin A\", \"Vitamin C\", \"Vitamin D\", \"Vitamin E\"]',1),(290,47,'Which of the following verbs is in the present perfect tense?','has written','[\"write\", \"writes\", \"has written\", \"wrote\"]',1),(291,47,'The play ______ by the time we arrived at the theater.','had started',NULL,1),(292,47,'Which of the following is an example of the past continuous tense?','was writing','[\"write\", \"writes\", \"was writing\", \"wrote\"]',1),(293,47,'By the time I ______ my homework, it was already midnight.','had finished',NULL,1),(294,47,'Which of the following verbs is in the future perfect tense?','will have written','[\"write\", \"writes\", \"will write\", \"will have written\"]',1),(295,48,'If I have 5 pencils and I get 2 more, how many pencils do I have now?','7','[\"5\", \"6\", \"7\", \"8\"]',1),(296,48,'The sum of 3 and 1 is ______','4',NULL,1),(297,48,'A bookshelf has 8 books on it. If 4 more books are added, how many books are on the bookshelf now?','12','[\"10\", \"11\", \"12\", \"13\"]',1),(298,48,'If I have 9 crayons and I get 1 more, the total number of crayons I have is ______','10',NULL,1),(299,48,'A basket contains 15 apples. If 3 more apples are put into the basket, how many apples are in the basket now?','18','[\"16\", \"17\", \"18\", \"19\"]',1),(300,48,'What is 2 + 1?','3','[\"1\", \"2\", \"3\", \"4\"]',1),(301,48,'The sum of 5 and 4 is ______','9',NULL,1),(302,48,'What is 7 + 0?','7','[\"5\", \"6\", \"7\", \"8\"]',1),(303,48,'If I have 3 pencils and I get 2 more, I have ______ pencils now','5',NULL,1),(304,48,'What is 1 + 6?','7','[\"5\", \"6\", \"7\", \"8\"]',1),(305,49,'By the time I ______ my homework, it was already midnight.','had finished','[\"finish\", \"have finished\", \"had finished\", \"was finishing\"]',1),(306,49,'If I ______ more time, I would have finished the project.','had',NULL,1),(307,49,'Which of the following sentences is in the past perfect tense?','I had eaten breakfast before I went to school','[\"I eat breakfast at 7 am\", \"I am eating breakfast now\", \"I had eaten breakfast before I went to school\", \"I will eat breakfast later\"]',1),(308,49,'The play ______ by the time we arrived at the theater.','had already started',NULL,1),(309,49,'Which of the following sentences is in the future perfect tense?','I will have finished my homework by 5 pm','[\"I finish my homework at 5 pm\", \"I am finishing my homework now\", \"I will finish my homework later\", \"I will have finished my homework by 5 pm\"]',1),(310,49,'By the time I ________ my homework, it was already midnight.','had finished','[\"finish\", \"have finished\", \"had finished\", \"was finishing\"]',1),(311,49,'If I ________ more time, I would have finished the project.','had',NULL,1),(312,49,'By next year, I ________ English for five years.','will have been studying','[\"study\", \"will study\", \"am studying\", \"will have been studying\"]',1),(313,49,'The teacher said that the students ________ their books by the end of the week.','would have read',NULL,1),(314,49,'If it ________ yesterday, we would have gone to the park.','hadn\'t rained','[\"rained\", \"didn\'t rain\", \"hadn\'t rained\", \"doesn\'t rain\"]',1);
/*!40000 ALTER TABLE `online_exam_questions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `online_exams`
--

DROP TABLE IF EXISTS `online_exams`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `online_exams` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `subject` varchar(100) NOT NULL,
  `section_id` int NOT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL,
  `duration_mins` int NOT NULL,
  `total_marks` int NOT NULL,
  `created_by` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `linked_exam_id` int DEFAULT NULL,
  `allow_copy` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `section_id` (`section_id`),
  KEY `created_by` (`created_by`),
  KEY `fk_online_primary` (`linked_exam_id`),
  CONSTRAINT `fk_online_primary` FOREIGN KEY (`linked_exam_id`) REFERENCES `exams` (`id`),
  CONSTRAINT `online_exams_ibfk_1` FOREIGN KEY (`section_id`) REFERENCES `sections` (`id`),
  CONSTRAINT `online_exams_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=50 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `online_exams`
--

LOCK TABLES `online_exams` WRITE;
/*!40000 ALTER TABLE `online_exams` DISABLE KEYS */;
INSERT INTO `online_exams` VALUES (1,'maths: fractions','maths',1,'2026-01-22 17:00:07','2026-01-22 19:00:07',30,5,6,'2026-01-22 10:30:27',3,0),(2,'maths: additions','maths',1,'2026-01-22 17:06:08','2026-01-22 19:06:08',30,5,6,'2026-01-22 10:36:45',4,0),(3,'maths: multiclations','maths',1,'2026-01-22 17:10:22','2026-01-22 19:10:22',5,5,6,'2026-01-22 10:41:06',5,0),(4,'maths: additions','maths',1,'2026-01-23 09:40:01','2026-01-23 11:40:01',10,5,6,'2026-01-23 03:11:11',7,0),(5,'maths: additions ','maths',1,'2026-01-26 08:38:52','2026-01-26 10:38:52',10,6,6,'2026-01-26 02:10:47',9,0),(6,'biology : nutrition','biology ',1,'2026-01-27 12:20:26','2026-01-27 14:20:26',10,6,9,'2026-01-27 05:52:42',10,0),(7,'maths: additions','maths',1,'2026-01-28 16:19:47','2026-01-28 18:19:47',30,5,6,'2026-01-28 09:50:09',11,0),(8,'maths: additions','maths',1,'2026-01-28 16:23:30','2026-01-28 18:23:30',30,5,6,'2026-01-28 09:54:00',12,0),(9,'sciencc: nutrition','sciencc',1,'2026-01-30 12:57:49','2026-01-30 14:57:49',30,5,6,'2026-01-30 06:28:22',13,0),(10,'maths: additions','maths',1,'2026-01-31 20:29:31','2026-01-31 22:29:31',30,6,6,'2026-01-31 14:00:20',14,0),(11,'Maths : Linear Algebra ','Maths ',1,'2026-02-10 10:08:43','2026-02-10 12:08:43',20,5,6,'2026-02-10 03:39:51',15,0),(12,'python : loops','python ',1,'2026-02-10 10:37:30','2026-02-10 12:37:30',10,5,6,'2026-02-10 04:07:50',16,0),(13,'Maths: Trigonometry ','Maths',1,'2026-02-11 10:04:36','2026-02-11 12:04:36',30,5,6,'2026-02-11 03:34:53',17,0),(14,'maths : Trigonometry ','maths ',1,'2026-02-11 12:15:56','2026-02-11 14:15:56',10,5,6,'2026-02-11 05:47:51',18,0),(15,'Maths: Number system ','Maths',1,'2026-02-13 11:15:02','2026-02-13 13:15:02',30,10,6,'2026-02-13 04:46:20',19,0),(16,'Science : plants ','Science ',1,'2026-02-13 11:22:29','2026-02-13 13:22:29',30,5,6,'2026-02-13 04:53:15',20,0),(17,'science : photosynthesis ','science ',1,'2026-02-13 12:07:54','2026-02-13 14:07:54',30,5,6,'2026-02-13 05:38:43',21,0),(18,'science : our environment ','science ',1,'2026-02-13 12:29:18','2026-02-13 14:29:18',30,5,6,'2026-02-13 06:01:11',22,0),(19,'English : verbs','English ',1,'2026-02-13 13:07:28','2026-02-13 15:07:28',10,5,6,'2026-02-13 06:38:08',23,0),(20,'Copy Allowed Test Exam','Testing',1,'2026-02-13 12:57:37','2026-02-13 13:57:37',60,10,8,'2026-02-13 07:27:40',25,1),(21,'English : nouns','English ',1,'2026-02-13 14:10:58','2026-02-13 16:10:58',20,10,6,'2026-02-13 07:42:58',26,0),(22,'Maths : ratios ','Maths ',1,'2026-02-13 14:13:44','2026-02-13 16:13:44',10,5,6,'2026-02-13 07:44:40',27,0),(23,'maths : function ','maths ',1,'2026-02-13 14:16:06','2026-02-13 16:16:06',30,5,6,'2026-02-13 07:47:24',28,0),(24,'English : noun','English ',1,'2026-02-13 14:21:45','2026-02-13 16:21:45',30,5,6,'2026-02-13 07:52:11',29,0),(25,'physics : friction ','physics ',1,'2026-02-13 14:30:03','2026-02-13 16:30:03',10,5,6,'2026-02-13 08:00:28',30,1),(26,'chemistry : chemical compounds ','chemistry ',1,'2026-02-13 14:31:04','2026-02-13 16:31:04',10,5,6,'2026-02-13 08:01:35',31,1),(27,'Maths: vectors','Maths',1,'2026-02-13 14:36:02','2026-02-13 16:36:02',15,5,6,'2026-02-13 08:06:32',32,1),(28,'English : pronoun ','English ',1,'2026-02-13 14:37:08','2026-02-13 16:37:08',15,5,6,'2026-02-13 08:07:30',33,1),(29,'Maths : linear Algebra ','Maths ',1,'2026-02-14 09:44:24','2026-02-14 11:44:24',20,10,6,'2026-02-14 03:14:56',34,1),(30,'science : living things ','science ',1,'2026-02-14 09:44:59','2026-02-14 11:44:59',30,5,6,'2026-02-14 03:15:20',35,1),(31,'Maths : linear Algebra ','Maths ',1,'2026-02-18 09:51:15','2026-02-18 11:51:15',30,5,6,'2026-02-18 03:21:38',36,1),(32,'Science : plants ','Science ',1,'2026-02-18 09:51:39','2026-02-18 11:51:39',30,10,6,'2026-02-18 03:22:01',37,1),(33,'science : nutrition ','science ',1,'2026-02-19 10:55:18','2026-02-19 12:55:18',30,5,6,'2026-02-19 04:25:34',38,1),(34,'English : verbs','English ',1,'2026-02-20 10:06:35','2026-02-20 12:06:35',30,5,6,'2026-02-20 03:36:59',39,1),(35,'Science : plants ','Science ',1,'2026-02-20 10:09:01','2026-02-20 12:09:01',30,5,6,'2026-02-20 03:39:19',40,0),(36,'science : nutrition ','science ',1,'2026-02-20 10:10:15','2026-02-20 12:10:15',30,5,6,'2026-02-20 03:40:32',41,0),(37,'English : verbs ','English ',1,'2026-02-21 10:05:04','2026-02-21 12:05:04',30,5,6,'2026-02-21 03:35:23',42,1),(38,'maths: linear Algebra ','maths',1,'2026-02-21 10:46:13','2026-02-21 12:46:13',30,10,6,'2026-02-21 04:16:47',43,0),(39,'Science : plants ','Science ',1,'2026-03-02 15:50:42','2026-03-02 17:50:42',30,5,6,'2026-03-02 09:21:08',44,1),(40,'mathematics : trigonometry','mathematics ',1,'2026-03-05 11:45:21','2026-03-05 13:45:21',30,5,6,'2026-03-05 05:16:34',45,1),(41,'maths : trigonometry ','maths ',1,'2026-03-16 11:09:37','2026-03-16 13:09:37',30,10,6,'2026-03-16 04:40:23',46,1),(42,'eng: verbs','eng',1,'2026-03-16 11:36:01','2026-03-16 13:36:01',30,10,6,'2026-03-16 05:06:25',47,0),(43,'English : Tenses ','English ',1,'2026-03-28 13:19:29','2026-03-28 15:19:29',30,15,6,'2026-03-28 06:50:32',48,0),(44,'Maths: Linear Algebra ','Maths',1,'2026-04-04 23:03:20','2026-04-05 01:03:20',30,10,6,'2026-04-04 16:33:56',50,1),(45,'English : verbs','English ',1,'2026-04-06 11:22:24','2026-04-06 13:22:24',30,10,6,'2026-04-06 04:52:55',51,1),(46,'Science : Nutrition ','Science ',1,'2026-04-06 11:23:17','2026-04-06 13:23:17',30,10,6,'2026-04-06 04:53:45',52,0),(47,'English : verbs ','English ',1,'2026-04-07 12:29:57','2026-04-07 14:29:57',30,5,6,'2026-04-07 06:00:11',53,0),(48,'maths: additions','maths',1,'2026-04-09 15:15:54','2026-04-09 17:15:54',30,10,6,'2026-04-09 08:47:04',57,1),(49,'English : Tenses ','English ',1,'2026-04-16 11:01:49','2026-04-16 13:01:49',30,10,6,'2026-04-16 04:32:29',58,0);
/*!40000 ALTER TABLE `online_exams` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `otp_codes`
--

DROP TABLE IF EXISTS `otp_codes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `otp_codes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `code` varchar(6) NOT NULL,
  `expires_at` timestamp NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_otp_user` (`user_id`),
  CONSTRAINT `fk_otp_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `otp_codes`
--

LOCK TABLES `otp_codes` WRITE;
/*!40000 ALTER TABLE `otp_codes` DISABLE KEYS */;
/*!40000 ALTER TABLE `otp_codes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `period_settings`
--

DROP TABLE IF EXISTS `period_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `period_settings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `period_number` int NOT NULL,
  `start_time` varchar(10) NOT NULL,
  `end_time` varchar(10) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `period_number` (`period_number`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `period_settings`
--

LOCK TABLES `period_settings` WRITE;
/*!40000 ALTER TABLE `period_settings` DISABLE KEYS */;
INSERT INTO `period_settings` VALUES (2,2,'9.00','9.45'),(4,3,'11','12'),(5,4,'10:50','11:40'),(6,5,'12:40','1:30'),(7,6,'2:20','3:10'),(12,1,'8:15','9:05');
/*!40000 ALTER TABLE `period_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `quiz_attempts`
--

DROP TABLE IF EXISTS `quiz_attempts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `quiz_attempts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` int NOT NULL,
  `subject` varchar(100) NOT NULL,
  `topic` varchar(255) DEFAULT NULL,
  `score` int NOT NULL,
  `total_questions` int NOT NULL,
  `time_taken_sec` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `student_id` (`student_id`),
  CONSTRAINT `quiz_attempts_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quiz_attempts`
--

LOCK TABLES `quiz_attempts` WRITE;
/*!40000 ALTER TABLE `quiz_attempts` DISABLE KEYS */;
/*!40000 ALTER TABLE `quiz_attempts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `resources`
--

DROP TABLE IF EXISTS `resources`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `resources` (
  `id` int NOT NULL AUTO_INCREMENT,
  `section_id` int DEFAULT NULL,
  `subject` varchar(100) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text,
  `file_url` varchar(255) NOT NULL,
  `type` varchar(50) NOT NULL,
  `uploaded_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `section_id` (`section_id`),
  KEY `uploaded_by` (`uploaded_by`),
  CONSTRAINT `resources_ibfk_1` FOREIGN KEY (`section_id`) REFERENCES `sections` (`id`) ON DELETE CASCADE,
  CONSTRAINT `resources_ibfk_2` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `resources`
--

LOCK TABLES `resources` WRITE;
/*!40000 ALTER TABLE `resources` DISABLE KEYS */;
INSERT INTO `resources` VALUES (16,1,'English ','Verbs ','','/uploads/resources/1776065889030-IV Yr Fee dues 10-04-2026 1.00 PM.xlsx','xlsx',6,'2026-04-13 07:38:09'),(17,1,'Mathematics ','Trigonometry ','','/uploads/resources/1776065918766-Time Table_B.Tech. II Year II Semester (R22C22) Supplementary Summative Assessment May-2026.pdf','pdf',6,'2026-04-13 07:38:40'),(18,1,'c','Arrays ','','/uploads/resources/1776065982553-Vignan\'s Foundation for Science, Technology & Rese, Guntur (Responses) - Final Selected.pdf','pdf',6,'2026-04-13 07:39:42');
/*!40000 ALTER TABLE `resources` ENABLE KEYS */;
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
  `grade` varchar(5) DEFAULT NULL,
  `remarks` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_result` (`exam_id`,`student_id`,`subject`),
  KEY `fk_result_student` (`student_id`),
  CONSTRAINT `fk_result_exam` FOREIGN KEY (`exam_id`) REFERENCES `exams` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_result_student` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=54 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `results`
--

LOCK TABLES `results` WRITE;
/*!40000 ALTER TABLE `results` DISABLE KEYS */;
INSERT INTO `results` VALUES (1,1,4,'Maths',85,'2025-12-31 05:02:11',NULL,NULL),(2,1,5,'Mathematics',85,'2025-12-31 09:12:25',NULL,NULL),(3,1,5,'Science',78,'2025-12-31 09:12:25',NULL,NULL),(4,1,5,'English',88,'2025-12-31 09:12:25',NULL,NULL),(5,1,5,'Social Studies',74,'2025-12-31 09:12:25',NULL,NULL),(9,4,5,'maths',5,'2026-01-22 10:37:52',NULL,'Online Exam: maths: additions'),(10,7,5,'maths',3,'2026-01-23 03:12:53',NULL,'Online Exam: maths: additions'),(11,7,5,'General',3,'2026-01-23 03:33:10','F','Online Exam: maths: additions'),(12,6,5,'General',50,'2026-01-23 03:33:26','D','good'),(16,10,5,'biology ',4,'2026-01-27 05:54:32',NULL,'Online Exam: biology : nutrition'),(17,10,5,'General',3,'2026-01-27 05:55:25','F','Online Exam: biology : nutrition'),(18,13,5,'sciencc',4,'2026-01-30 09:38:50',NULL,'Online Exam: sciencc: nutrition'),(19,13,5,'General',3,'2026-01-31 13:57:30','F','Online Exam: sciencc: nutrition'),(21,14,5,'maths',1,'2026-01-31 14:02:56',NULL,'Online Exam: maths: additions'),(22,17,5,'Maths',1,'2026-02-11 05:45:08',NULL,'Online Exam: Maths: Trigonometry '),(23,18,5,'maths ',1,'2026-02-11 05:52:37',NULL,'Online Exam: maths : Trigonometry '),(24,20,5,'Science ',5,'2026-02-13 05:11:45',NULL,'Online Exam: Science : plants '),(25,21,5,'science ',5,'2026-02-13 05:45:47',NULL,'Online Exam: science : photosynthesis '),(26,22,5,'science ',5,'2026-02-13 06:02:02',NULL,'Online Exam: science : our environment '),(41,23,5,'English ',3,'2026-02-13 06:38:48',NULL,'Online Exam: English : verbs'),(42,31,5,'chemistry ',2,'2026-02-13 08:02:20',NULL,'Online Exam: chemistry : chemical compounds '),(43,32,5,'Maths',1,'2026-02-13 08:11:15',NULL,'Online Exam: Maths: vectors'),(44,35,5,'science ',1,'2026-02-14 03:34:12',NULL,'Online Exam: science : living things '),(45,41,5,'science ',4,'2026-02-20 03:59:03',NULL,'Online Exam: science : nutrition '),(46,42,5,'English ',0,'2026-02-21 04:13:48',NULL,'Online Exam: English : verbs '),(47,45,5,'mathematics ',0,'2026-03-05 05:17:09',NULL,'Online Exam: mathematics : trigonometry'),(48,53,5,'English ',1,'2026-04-07 06:01:39',NULL,'Online Exam: English : verbs '),(49,54,4,'General',95,'2026-04-09 05:25:13','A+','good'),(50,54,5,'General',70,'2026-04-09 05:25:13','B','need improvement '),(51,56,4,'maths',90,'2026-04-09 08:44:43','A+','good'),(52,56,5,'maths',99,'2026-04-09 08:44:43','A+','excellent '),(53,57,5,'maths',9,'2026-04-09 08:48:39',NULL,'Online Exam: maths: additions');
/*!40000 ALTER TABLE `results` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sections`
--

DROP TABLE IF EXISTS `sections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sections` (
  `id` int NOT NULL AUTO_INCREMENT,
  `class` varchar(10) NOT NULL,
  `section` varchar(5) NOT NULL,
  `name` varchar(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_class_section` (`class`,`section`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sections`
--

LOCK TABLES `sections` WRITE;
/*!40000 ALTER TABLE `sections` DISABLE KEYS */;
INSERT INTO `sections` VALUES (1,'10','A','10-A'),(3,'9','A','9A'),(4,'8','A','8A'),(5,'7','A','7A'),(6,'5','A','5A');
/*!40000 ALTER TABLE `sections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `student_homework_status`
--

DROP TABLE IF EXISTS `student_homework_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `student_homework_status` (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` int NOT NULL,
  `homework_id` int NOT NULL,
  `is_completed` tinyint(1) DEFAULT '0',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_status` (`student_id`,`homework_id`),
  KEY `homework_id` (`homework_id`),
  CONSTRAINT `fk_shs_student` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `student_homework_status_ibfk_2` FOREIGN KEY (`homework_id`) REFERENCES `homework` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=305 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student_homework_status`
--

LOCK TABLES `student_homework_status` WRITE;
/*!40000 ALTER TABLE `student_homework_status` DISABLE KEYS */;
INSERT INTO `student_homework_status` VALUES (1,7,1,0,'2026-04-16 04:57:35'),(2,7,2,0,'2026-04-16 04:56:18'),(41,7,3,1,'2026-04-16 04:56:21'),(44,7,4,1,'2026-04-07 08:27:44'),(166,7,7,1,'2026-04-07 08:27:18'),(169,7,8,1,'2026-04-07 08:27:43'),(216,7,9,1,'2026-02-20 06:34:36'),(250,7,10,1,'2026-04-07 08:26:59'),(258,7,13,1,'2026-04-07 05:51:27'),(259,7,11,1,'2026-04-07 08:26:59'),(267,7,12,1,'2026-04-07 06:24:29'),(295,7,14,0,'2026-04-16 04:55:26');
/*!40000 ALTER TABLE `student_homework_status` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `student_performance`
--

DROP TABLE IF EXISTS `student_performance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `student_performance` (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` int NOT NULL,
  `teacher_id` int NOT NULL,
  `performance_text` text,
  `rating` varchar(20) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `student_id` (`student_id`),
  KEY `teacher_id` (`teacher_id`),
  CONSTRAINT `student_performance_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `student_performance_ibfk_2` FOREIGN KEY (`teacher_id`) REFERENCES `teachers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student_performance`
--

LOCK TABLES `student_performance` WRITE;
/*!40000 ALTER TABLE `student_performance` DISABLE KEYS */;
INSERT INTO `student_performance` VALUES (1,7,7,'performing well','Good','2026-02-19 07:38:42','2026-02-19 07:38:42'),(2,7,7,'Need to improve in science','Average','2026-02-19 07:42:30','2026-02-19 07:42:30'),(3,7,7,'good','Excellent','2026-02-19 08:39:11','2026-02-19 08:39:11'),(4,3,7,'good','Average','2026-02-21 04:15:42','2026-02-21 04:15:42');
/*!40000 ALTER TABLE `student_performance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `student_performances`
--

DROP TABLE IF EXISTS `student_performances`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `student_performances` (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` int NOT NULL,
  `teacher_id` int NOT NULL,
  `performance_rating` enum('Good','Bad','Need to improve') NOT NULL,
  `remarks` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `student_id` (`student_id`),
  KEY `teacher_id` (`teacher_id`),
  CONSTRAINT `student_performances_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `student_performances_ibfk_2` FOREIGN KEY (`teacher_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student_performances`
--

LOCK TABLES `student_performances` WRITE;
/*!40000 ALTER TABLE `student_performances` DISABLE KEYS */;
INSERT INTO `student_performances` VALUES (1,7,6,'Good','prepare well ','2026-03-09 04:54:16','2026-03-09 04:54:16'),(2,7,6,'Need to improve','improve in science subject ','2026-03-09 05:05:16','2026-03-09 05:05:16'),(3,7,6,'Good','','2026-03-23 04:00:28','2026-03-23 04:00:28'),(4,7,6,'Good','','2026-03-23 04:00:42','2026-03-23 04:00:42'),(5,3,6,'Need to improve','','2026-03-23 04:00:52','2026-03-23 04:00:52'),(6,7,6,'Need to improve','','2026-03-23 07:05:29','2026-03-23 07:05:29'),(7,7,6,'Good','good','2026-04-02 05:29:46','2026-04-02 05:29:46'),(8,7,6,'Good','good','2026-04-02 05:29:54','2026-04-02 05:29:54');
/*!40000 ALTER TABLE `student_performances` ENABLE KEYS */;
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
  `section_id` int DEFAULT NULL,
  `roll_no` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `students_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `students`
--

LOCK TABLES `students` WRITE;
/*!40000 ALTER TABLE `students` DISABLE KEYS */;
INSERT INTO `students` VALUES (4,3,'Rahul Kumar','10','A','23',NULL,NULL,NULL,'2025-12-30 05:56:19',1,NULL),(5,7,'Test Student','10','A','01',NULL,NULL,NULL,'2025-12-31 06:14:32',1,NULL),(6,10,'tej','9','A','21',NULL,NULL,NULL,'2026-01-11 05:08:02',3,NULL);
/*!40000 ALTER TABLE `students` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `study_plans`
--

DROP TABLE IF EXISTS `study_plans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `study_plans` (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` int NOT NULL,
  `week_start_date` date NOT NULL,
  `plan_json` json NOT NULL,
  `progress_pct` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `student_id` (`student_id`),
  CONSTRAINT `study_plans_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `study_plans`
--

LOCK TABLES `study_plans` WRITE;
/*!40000 ALTER TABLE `study_plans` DISABLE KEYS */;
/*!40000 ALTER TABLE `study_plans` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `substitutions`
--

DROP TABLE IF EXISTS `substitutions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `substitutions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `absence_id` int NOT NULL,
  `date` date NOT NULL,
  `period` int NOT NULL,
  `section_id` int NOT NULL,
  `original_teacher_id` int NOT NULL,
  `substitute_teacher_id` int NOT NULL,
  `remarks` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `absence_id` (`absence_id`),
  KEY `section_id` (`section_id`),
  KEY `original_teacher_id` (`original_teacher_id`),
  KEY `substitute_teacher_id` (`substitute_teacher_id`),
  CONSTRAINT `substitutions_ibfk_1` FOREIGN KEY (`absence_id`) REFERENCES `teacher_absences` (`id`),
  CONSTRAINT `substitutions_ibfk_2` FOREIGN KEY (`section_id`) REFERENCES `sections` (`id`),
  CONSTRAINT `substitutions_ibfk_3` FOREIGN KEY (`original_teacher_id`) REFERENCES `teachers` (`id`),
  CONSTRAINT `substitutions_ibfk_4` FOREIGN KEY (`substitute_teacher_id`) REFERENCES `teachers` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `substitutions`
--

LOCK TABLES `substitutions` WRITE;
/*!40000 ALTER TABLE `substitutions` DISABLE KEYS */;
INSERT INTO `substitutions` VALUES (1,25,'2026-02-08',3,1,8,8,NULL,'2026-02-08 10:01:41'),(2,26,'2026-02-08',3,1,8,9,NULL,'2026-02-08 10:01:42'),(3,27,'2026-02-08',3,1,7,10,NULL,'2026-02-08 10:08:24'),(4,28,'2026-02-14',3,1,8,7,'','2026-02-14 06:20:30'),(5,29,'2026-02-18',2,1,8,9,'','2026-02-18 04:24:58'),(6,30,'2026-02-19',2,1,7,9,'','2026-02-19 08:36:50'),(7,31,'2026-02-19',2,1,7,9,'','2026-02-19 10:05:37'),(8,32,'2026-02-20',6,1,9,8,'','2026-02-20 04:01:49'),(9,33,'2026-02-21',2,1,10,7,'','2026-02-21 04:18:26'),(10,34,'2026-03-10',3,1,7,10,'AI Suggested','2026-03-10 03:46:20'),(11,35,'2026-03-10',3,3,9,10,'AI Suggested','2026-03-10 06:44:25'),(12,36,'2026-03-23',2,1,8,7,'AI Suggested','2026-03-23 04:05:38'),(13,36,'2026-03-23',2,1,8,7,'AI Suggested','2026-03-23 04:05:38');
/*!40000 ALTER TABLE `substitutions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `teacher_absences`
--

DROP TABLE IF EXISTS `teacher_absences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `teacher_absences` (
  `id` int NOT NULL AUTO_INCREMENT,
  `teacher_id` int NOT NULL,
  `absence_date` date NOT NULL,
  `reason` varchar(255) DEFAULT NULL,
  `marked_by` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `teacher_id` (`teacher_id`),
  CONSTRAINT `teacher_absences_ibfk_1` FOREIGN KEY (`teacher_id`) REFERENCES `teachers` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `teacher_absences`
--

LOCK TABLES `teacher_absences` WRITE;
/*!40000 ALTER TABLE `teacher_absences` DISABLE KEYS */;
INSERT INTO `teacher_absences` VALUES (1,7,'2026-01-23','sick',8,'2026-01-23 04:13:01'),(2,7,'2026-01-23','',8,'2026-01-23 04:16:45'),(3,8,'2026-01-23','',8,'2026-01-23 04:16:57'),(4,7,'2026-01-23','',8,'2026-01-23 05:34:06'),(5,9,'2026-01-23','sick ',8,'2026-01-23 05:35:54'),(6,8,'2026-01-23','sss',8,'2026-01-23 09:58:25'),(7,9,'2026-01-24','sick',8,'2026-01-24 02:58:58'),(8,8,'2026-02-06','trip',8,'2026-02-06 09:59:57'),(9,8,'2026-02-06','trip',8,'2026-02-06 09:59:58'),(10,8,'2026-02-06','trip',8,'2026-02-06 10:00:06'),(11,8,'2026-02-06','trip',8,'2026-02-06 10:00:07'),(12,7,'2026-02-06','trip',8,'2026-02-06 10:00:14'),(13,7,'2026-02-06','trip',8,'2026-02-06 10:00:25'),(14,10,'2026-02-08','Substitution Assigned',8,'2026-02-08 09:24:37'),(15,10,'2026-02-08','Substitution Assigned',8,'2026-02-08 09:24:41'),(16,10,'2026-02-08','Substitution Assigned',8,'2026-02-08 09:24:42'),(17,10,'2026-02-08','Substitution Assigned',8,'2026-02-08 09:24:43'),(18,10,'2026-02-08','Substitution Assigned',8,'2026-02-08 09:24:43'),(19,8,'2026-02-08','Substitution Assigned',8,'2026-02-08 09:33:08'),(20,10,'2026-02-08','Substitution Assigned',8,'2026-02-08 09:49:59'),(21,10,'2026-02-08','Substitution Assigned',8,'2026-02-08 09:50:02'),(22,8,'2026-02-08','Substitution Assigned',8,'2026-02-08 09:50:36'),(23,9,'2026-02-08','Substitution Assigned',8,'2026-02-08 09:54:40'),(24,9,'2026-02-08','Substitution Assigned',8,'2026-02-08 09:54:59'),(25,8,'2026-02-08','Substitution Assigned',8,'2026-02-08 10:01:40'),(26,8,'2026-02-08','Substitution Assigned',8,'2026-02-08 10:01:41'),(27,7,'2026-02-08','Substitution Assigned',8,'2026-02-08 10:08:23'),(28,8,'2026-02-14','Substitution Assigned',8,'2026-02-14 06:20:29'),(29,8,'2026-02-18','Substitution Assigned',8,'2026-02-18 04:24:57'),(30,7,'2026-02-19','Substitution Assigned',8,'2026-02-19 08:36:50'),(31,7,'2026-02-19','Substitution Assigned',8,'2026-02-19 10:05:36'),(32,9,'2026-02-20','Substitution Assigned',8,'2026-02-20 04:01:49'),(33,10,'2026-02-21','Substitution Assigned',8,'2026-02-21 04:18:26'),(34,7,'2026-03-10','Auto-generated for Substitution',1,'2026-03-10 03:46:20'),(35,9,'2026-03-10','Auto-generated for Substitution',1,'2026-03-10 06:44:25'),(36,8,'2026-03-23','Auto-generated for Substitution',1,'2026-03-23 04:05:37');
/*!40000 ALTER TABLE `teacher_absences` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `teacher_subject_mappings`
--

DROP TABLE IF EXISTS `teacher_subject_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `teacher_subject_mappings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `teacher_id` int NOT NULL,
  `section_id` int NOT NULL,
  `subject_name` varchar(100) NOT NULL,
  `role` varchar(50) DEFAULT NULL,
  `academic_year` varchar(10) NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_mapping` (`teacher_id`,`section_id`,`subject_name`,`academic_year`),
  KEY `section_id` (`section_id`),
  CONSTRAINT `teacher_subject_mappings_ibfk_1` FOREIGN KEY (`teacher_id`) REFERENCES `teachers` (`id`),
  CONSTRAINT `teacher_subject_mappings_ibfk_2` FOREIGN KEY (`section_id`) REFERENCES `sections` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `teacher_subject_mappings`
--

LOCK TABLES `teacher_subject_mappings` WRITE;
/*!40000 ALTER TABLE `teacher_subject_mappings` DISABLE KEYS */;
INSERT INTO `teacher_subject_mappings` VALUES (1,9,5,'science','class_teacher','2024-25',0,'2026-01-28 03:35:00'),(3,7,1,'maths','class_teacher','2025-26',1,'2026-01-28 03:35:31'),(6,8,3,'c program','class_teacher','2025-26',1,'2026-01-28 03:36:00'),(7,8,1,'python','Subject Teacher','2024-2025',1,'2026-02-08 08:17:00'),(8,7,1,'English','Subject Teacher','2024-2025',0,'2026-02-18 04:24:35'),(9,7,1,'maths','Subject Teacher','2024-2025',1,'2026-02-18 06:14:05'),(11,7,1,'physics','Class Teacher','2024-2025',1,'2026-02-21 04:18:12'),(12,8,5,'physics','Subject Teacher','2024-2025',0,'2026-02-25 06:00:21'),(13,8,1,'physics','Subject Teacher','2024-2025',1,'2026-02-25 06:01:09'),(14,8,6,'English ','class_teacher','2024-25',1,'2026-03-09 06:28:21'),(15,8,6,'Physics ','mentor','2024-2025',1,'2026-03-10 04:00:49'),(16,7,1,'msths','subject_teacher','2024-2025',1,'2026-03-10 06:44:10'),(17,8,5,'python ','mentor','2024-2025',1,'2026-03-23 04:05:09');
/*!40000 ALTER TABLE `teacher_subject_mappings` ENABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `teachers`
--

LOCK TABLES `teachers` WRITE;
/*!40000 ALTER TABLE `teachers` DISABLE KEYS */;
INSERT INTO `teachers` VALUES (7,6,'Mr. Sharma','Mathematics','','2025-12-30 08:14:45'),(8,9,'Sathvika','C Programming','9603550044','2026-01-11 05:06:32'),(9,11,'Ravi ','science ','8185864150','2026-01-23 05:11:43'),(10,12,'Mrs.Lalaitha','BDA','1234567890','2026-01-28 09:56:29');
/*!40000 ALTER TABLE `teachers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `timetable`
--

DROP TABLE IF EXISTS `timetable`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `timetable` (
  `id` int NOT NULL AUTO_INCREMENT,
  `section_id` int NOT NULL,
  `day` enum('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday') NOT NULL,
  `period` int NOT NULL,
  `subject` varchar(50) NOT NULL,
  `teacher_name` varchar(100) NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_slot` (`section_id`,`day`,`period`),
  CONSTRAINT `fk_timetable_section` FOREIGN KEY (`section_id`) REFERENCES `sections` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `timetable`
--

LOCK TABLES `timetable` WRITE;
/*!40000 ALTER TABLE `timetable` DISABLE KEYS */;
INSERT INTO `timetable` VALUES (2,1,'Monday',2,'BDA','Mrs.Lalaitha','00:00:09','00:00:09','2026-01-07 05:52:44'),(4,1,'Wednesday',1,'c program','sathvi','09:15:00','10:25:00','2026-01-07 06:48:02'),(7,1,'Tuesday',1,'c program','Sathvika','09:00:00','09:50:00','2026-01-11 05:43:08'),(9,1,'Monday',4,'python','Mr. Sharma','10:50:00','11:40:00','2026-01-11 05:57:35'),(10,1,'Saturday',1,'python','Ravi ','09:00:00','09:50:00','2026-01-24 02:57:13'),(11,1,'Tuesday',2,'python','Ravi ','00:00:09','00:00:09','2026-01-24 04:05:20'),(12,3,'Tuesday',3,'science ','Ravi ','10:00:00','10:50:00','2026-01-24 04:15:38'),(13,1,'Monday',3,'c program','Sathvika','10:00:00','10:50:00','2026-01-28 03:37:25'),(17,1,'Friday',2,'c','Mr. Sharma','00:00:09','00:00:09','2026-02-06 11:21:18'),(18,1,'Wednesday',3,'c','Ravi ','10:00:00','10:50:00','2026-02-06 11:21:33'),(19,4,'Monday',1,'c','Sathvika','08:15:00','09:05:00','2026-02-07 05:09:56'),(21,1,'Tuesday',4,'c','Mrs.Lalaitha','10:50:00','11:40:00','2026-02-07 05:35:56'),(22,1,'Monday',5,'python ','Ravi ','12:40:00','01:30:00','2026-02-08 06:59:30'),(24,6,'Monday',1,'Science ','Mrs.Lalaitha','08:15:00','09:05:00','2026-02-08 07:11:49'),(25,1,'Friday',3,'eng','Mrs.Lalaitha','00:00:11','00:00:12','2026-03-12 08:42:15'),(26,1,'Monday',6,'Mathematics','Mr. Sharma','02:20:00','03:10:00','2026-03-30 05:00:26'),(33,1,'Monday',1,'science ','Ravi ','08:15:00','09:05:00','2026-04-02 05:27:48');
/*!40000 ALTER TABLE `timetable` ENABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (3,'student@test.com','$2b$10$147frUFd/eYTnmoVEeaW9.45jQP2VFCW3h518uAt4qq4ip5e54eNG','student',1,'2025-12-30 05:50:58'),(6,'teacher@test.com','$2b$10$me10Kuns/JRLrM0ERdS27u8/E47.BjrXZM2Kwte45dKvbc17iFz86','teacher',1,'2025-12-30 08:11:05'),(7,'test@student.com','$2b$10$70Ru/Z1ZbMVsbiYlfeMZKe/eXWTXkalwMEEY.yAmqGm.DAt31gZuO','student',1,'2025-12-31 06:14:07'),(8,'admin@test.com','$2b$10$Nhj7C6ijiNWke02dJxnhO.NKljuhTWQM4PP/0TrAmzGbv5vv/mcn2','admin',1,'2026-01-11 05:01:36'),(9,'sathvikach2004@gmail.com','$2b$10$Tc9CX4Jf/d1y4K7GtA/fRu/l4gbNBUcgKDhP.NGD8C2yjln8RYymK','teacher',1,'2026-01-11 05:06:32'),(10,'teja@gmail.com','$2b$10$zTWr1bMM4csafPiq6ciaZuHMc6GNXTg.HUnKZybMGaZDVM9B6uELe','student',1,'2026-01-11 05:08:02'),(11,'ravivaka81gmail.com','$2b$10$hvyIU1QmX8KQG0llmNb6C.Ez3Q.Hadg2/IoFLvu7DfAaqiy6UEcHq','teacher',1,'2026-01-23 05:11:43'),(12,'Lalie@gmail.com','$2b$10$rnt8rHM/4zuUqtuFT58e6.D1qzXwsoaFq7uLQK800w9KznhKvA1CO','teacher',1,'2026-01-28 09:56:29');
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

-- Dump completed on 2026-04-17 15:59:44
