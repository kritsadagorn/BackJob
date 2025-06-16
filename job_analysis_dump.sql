-- MySQL dump 10.13  Distrib 8.0.42, for Linux (x86_64)
--
-- Host: localhost    Database: job_analysis
-- ------------------------------------------------------
-- Server version	8.0.42-0ubuntu0.24.04.1

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
-- Table structure for table `_prisma_migrations`
--

DROP TABLE IF EXISTS `_prisma_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `_prisma_migrations` (
  `id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `checksum` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `finished_at` datetime(3) DEFAULT NULL,
  `migration_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `logs` text COLLATE utf8mb4_unicode_ci,
  `rolled_back_at` datetime(3) DEFAULT NULL,
  `started_at` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `applied_steps_count` int unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `_prisma_migrations`
--

LOCK TABLES `_prisma_migrations` WRITE;
/*!40000 ALTER TABLE `_prisma_migrations` DISABLE KEYS */;
/*!40000 ALTER TABLE `_prisma_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_skills`
--

DROP TABLE IF EXISTS `job_skills`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_skills` (
  `id` int NOT NULL AUTO_INCREMENT,
  `job_id` int DEFAULT NULL,
  `skill_id` int DEFAULT NULL,
  `score` int DEFAULT '0',
  UNIQUE KEY `job_id` (`id`),
  KEY `job_skills_jobs_FK` (`job_id`),
  KEY `job_skills_skills_FK` (`skill_id`),
  CONSTRAINT `job_skills_ibfk_1` FOREIGN KEY (`skill_id`) REFERENCES `skills` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `job_skills_position_FK` FOREIGN KEY (`job_id`) REFERENCES `position` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=58 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_skills`
--

LOCK TABLES `job_skills` WRITE;
/*!40000 ALTER TABLE `job_skills` DISABLE KEYS */;
INSERT INTO `job_skills` VALUES (1,1,1,50),(2,1,2,20),(3,1,3,70),(4,1,4,80),(5,2,2,10),(6,3,3,25);
/*!40000 ALTER TABLE `job_skills` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `position`
--

DROP TABLE IF EXISTS `position`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `position` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `group_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  KEY `position_position_group_FK` (`group_id`),
  CONSTRAINT `position_position_group_FK` FOREIGN KEY (`group_id`) REFERENCES `position_group` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `position`
--

LOCK TABLES `position` WRITE;
/*!40000 ALTER TABLE `position` DISABLE KEYS */;
INSERT INTO `position` VALUES (1,'Frontend Developer',2),(2,'Backend Developer',2),(3,'Game Developer',2),(4,'Systems Analyst',9),(5,'Network Engineer',3),(6,'Automation Engineer',1),(7,'Quality Assuarance Engineer (QA)',2),(8,'Data Engineer',6),(9,'Data Analyst',6),(10,'Software Engineer',2),(11,'Full-Stack Developer',2),(12,'System Engineer',9),(13,'Java Developer',2),(14,'Security Engineer',4),(15,'Data Scientist',6),(16,'Applications Developer',2),(17,'DevOps Engineer',2),(18,'Android Developer',2);
/*!40000 ALTER TABLE `position` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `position_details`
--

DROP TABLE IF EXISTS `position_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `position_details` (
  `id` int NOT NULL AUTO_INCREMENT,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `position_id` int NOT NULL,
  `trending_level` int NOT NULL,
  `description` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `responsibilities` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  PRIMARY KEY (`id`),
  KEY `position_id` (`position_id`),
  KEY `jobs_trending_FK` (`trending_level`),
  CONSTRAINT `jobs_trending_FK` FOREIGN KEY (`trending_level`) REFERENCES `trending` (`id`),
  CONSTRAINT `position_details_ibfk_2` FOREIGN KEY (`position_id`) REFERENCES `position` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `position_details`
--

LOCK TABLES `position_details` WRITE;
/*!40000 ALTER TABLE `position_details` DISABLE KEYS */;
INSERT INTO `position_details` VALUES (3,'2025-03-01 22:00:22','2025-03-01 22:00:22',1,1,'A front-end developer is a type of software developer who creates the user-facing side of websites and applications. They are well-versed in web development languages such as HTML, CSS, and JavaScript that are designed for coding dynamic, interactive user experiences. Anytime you enjoy the look and feel of a digital product, website, or application','Front-end developers are responsible for designing and implementing the user interface (UI) and user experience (UX) of a website or web application. This includes translating designs into functional code using languages like HTML, CSS, and JavaScript.'),(4,'2025-03-01 22:00:22','2025-03-01 22:00:22',2,1,'A backend developer is a software engineer who builds and maintains the server-side logic, databases, and APIs that power websites and applications. Proficient in languages like Python, Java, Ruby, or Node.js, they ensure data flows seamlessly between servers and user interfaces. Every time you log in, make a purchase, or stream content online, a backend developer’s code is working behind the scenes to make it happen.','Backend developers are responsible for the server-side logic and infrastructure of a web application or software. They handle tasks like database management, API development, and ensuring the application\'s functionality and security. '),(5,'2025-03-01 22:00:22','2025-03-01 22:00:22',3,2,'A game developer helps transform games from a concept to a playable reality. They do this by coding visual elements and features, and testing iterations until a game is ready for market. If you love video games and enjoy working with computers, a career in video game development can be immensely rewarding.','Game developers, often part of larger teams, translate game designs and concepts into playable video games. Their responsibilities include writing code, integrating graphics, and testing the game\'s functionality and performance. They also collaborate with artists and other developers to ensure the game\'s cohesive vision and execution. '),(6,'2025-03-01 22:00:22','2025-03-01 22:00:22',4,2,'System analysis involves a deep examination of a system to understand its structure, functionality, and interactions. System analysts use this analysis to identify areas for improvement, propose solutions, and ultimately design and implement systems that meet specific needs and business requirements. They act as a bridge between business needs and technology, ensuring that systems effectively support organizational goals. ','A systems analyst\'s responsibilities revolve around analyzing, designing, and improving computer systems to align with business needs. They gather requirements from users, translate them into technical specifications, and work with developers to implement solutions.'),(7,'2025-03-01 22:00:22','2025-03-01 22:00:22',5,3,'Network engineers are responsible for designing, implementing, and maintaining computer networks within organizations. They ensure smooth and secure communication and data transfer, including local area networks (LANs), wide area networks (WANs), and intranets.','Network engineers are responsible for designing, implementing, and maintaining computer networks, ensuring they operate efficiently and securely. This includes tasks like installing and configuring network equipment, troubleshooting issues, and implementing security measures.'),(8,'2025-03-01 22:00:22','2025-03-01 22:00:22',6,3,'An automation engineer designs, develops, and implements automated systems to streamline processes and improve efficiency in various industries. They use technology to automate tasks, reduce human intervention, and optimize operations. This can involve working with software, hardware, and robotics to achieve desired outcomes. ','Automation engineers are responsible for designing, implementing, and maintaining automated systems to improve efficiency and reduce human intervention in various industries.'),(16,'2025-03-20 14:13:18','2025-03-20 14:13:18',7,1,'A QA (Quality Assurance) engineer\'s primary role is to ensure that software products meet quality standards and expectations before release. They do this by designing, executing, and analyzing tests to identify defects and vulnerabilities, ultimately ensuring a high-quality user experience. ','A QA (Quality Assurance) engineer\'s primary responsibility is to ensure products or services meet specified quality standards before they are released to users.'),(17,'2025-03-20 14:13:18','2025-03-20 14:13:18',8,1,'Data engineers design, build, and maintain data infrastructure to ensure accurate and timely data accessibility for organizations. They focus on building and optimizing data pipelines, transforming raw data into usable formats, and creating efficient storage systems. This allows data scientists, analysts, and business users to leverage data for decision-making and performance optimization. ','A data engineer\'s primary responsibility is to design, build, and maintain the infrastructure for managing and processing data. This includes creating data pipelines, developing data storage systems, and ensuring data quality and accessibility for various users, including data scientists, business analysts, and application developers. '),(18,'2025-03-20 14:13:18','2025-03-20 14:13:18',9,2,'A Data Analysis Engineer, also known as an Analytics Engineer, focuses on ensuring data is readily accessible and usable for analysis and decision-making. They design, build, and maintain data pipelines, ensuring data is properly transformed and stored, making it easily accessible for data analysts and business users. ','A data analyst\'s primary responsibility is to collect, analyze, and interpret data to identify trends, patterns, and insights that can be used to make informed decisions according to Pecan AI.'),(19,'2025-03-20 14:13:18','2025-03-20 14:13:18',10,1,'Software engineers are responsible for designing, developing, testing, and maintaining software systems. They apply engineering principles and knowledge of programming languages to build solutions for end users. This includes creating various software like computer games, business applications, and operating systems, as well as working on things like network control systems and middleware. ','Software engineers are responsible for designing, developing, and maintaining software systems. They collaborate with teams to create and enhance software applications, ensuring they meet user needs and industry standards. This involves various tasks like coding, testing, debugging, and documenting software solutions. '),(20,'2025-03-01 22:00:22','2025-03-01 22:00:22',11,1,'A full-stack developer is a versatile software engineer who can work on both the front-end (client-side) and back-end (server-side) of a web application or software project. They are responsible for designing, developing, and maintaining the entire application, from the user interface to the database. ','A Full-Stack Engineer is responsible for building and maintaining both the front-end (user interface) and back-end (server-side logic) of software applications. They work on everything from designing the user experience to developing the infrastructure that supports the application. '),(21,'2025-03-01 22:00:22','2025-03-01 22:00:22',12,1,'A systems engineer designs, implements, and manages complex systems, ensuring they are efficient, functional, and safe. They oversee all aspects of a project, from conception to completion, and collaborate with various teams to optimize systems and improve overall performance. This includes designing, testing, and integrating components, as well as troubleshooting issues and providing technical assistance. ','A systems engineer designs, implements, and maintains the technical infrastructure that supports an organization\'s operations. They troubleshoot technical issues, ensure system stability, and optimize performance. Key responsibilities include assessing systems, designing and upgrading infrastructure, and brainstorming improvements. '),(22,'2025-03-01 22:00:22','2025-03-01 22:00:22',13,2,'Java developers use the Java programming language to create and maintain software applications. They are involved in all stages of the software development lifecycle, from design and implementation to testing and maintenance. This includes tasks like analyzing user needs, writing code, testing applications, and troubleshooting issues. ','A Java developer designs, develops, and maintains Java-based applications and systems, ensuring they meet user needs and adhere to specifications. They write, test, debug, and troubleshoot code, collaborate with other developers, and participate in software development lifecycle stages. '),(23,'2025-03-01 22:00:22','2025-03-01 22:00:22',14,2,'A security engineer\'s primary role is to protect an organization\'s systems, networks, and data from cyber threats. They implement and maintain security systems, respond to incidents, and conduct security assessments to identify and mitigate vulnerabilities. ','Security engineers are responsible for designing, implementing, and maintaining security measures to protect computer systems, networks, and data from cyber threats. They identify vulnerabilities, respond to security incidents, and develop security protocols to safeguard an organization\'s digital infrastructure. '),(24,'2025-03-01 22:00:22','2025-03-01 22:00:22',15,3,'Data scientists use analytical, statistical, and programming skills to extract meaningful insights from large datasets. They collect, clean, analyze, and interpret data to identify patterns, make predictions, and inform decision-making across various industries. Essentially, they transform data into actionable knowledge that can be used to solve problems and improve outcomes. ','Data scientists analyze large datasets to extract meaningful insights, which they then use to make business recommendations and solve problems. Their responsibilities include collecting, cleaning, and analyzing data, building predictive models, and communicating findings to stakeholders.'),(25,'2025-03-01 22:00:22','2025-03-01 22:00:22',16,3,'Application developers are software engineers who create, maintain, and update applications for various platforms like mobile devices, web platforms, and desktop computers. They translate user needs into functional software solutions by writing code, testing applications, and troubleshooting issues. ','An application developer designs, codes, tests, and maintains software applications. They translate client requirements into functional software by writing code, debugging issues, and ensuring the application meets user and business needs.'),(26,'2025-03-20 14:13:18','2025-03-20 14:13:18',17,3,'DevOps engineers are key to bridging the gap between software development and IT operations, streamlining the software development lifecycle through automation and collaboration. They focus on continuous integration and continuous delivery (CI/CD), infrastructure management, and automating various tasks to accelerate software delivery. ','They are responsible for managing environments for continuous integration (CI) and continuous delivery (CD), automating tasks, monitoring system performance, and ensuring security. '),(27,'2025-03-20 14:13:18','2025-03-20 14:13:18',18,1,'Android is a mobile operating system (OS) developed by Google that powers a wide range of devices, including smartphones, tablets, watches, TVs, and cars. It acts as the software that controls the hardware and manages the user interface, enabling devices to perform various functions and interact with applications. ','An Android Developer is responsible for designing, building, testing, and maintaining applications for devices running the Android operating system.');
/*!40000 ALTER TABLE `position_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `position_group`
--

DROP TABLE IF EXISTS `position_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `position_group` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `position_group`
--

LOCK TABLES `position_group` WRITE;
/*!40000 ALTER TABLE `position_group` DISABLE KEYS */;
INSERT INTO `position_group` VALUES (1,'Hardware Engineering'),(2,'Software Engineering'),(3,'Network Engineering'),(4,'Cybersecurity'),(5,'Cloud Engineering'),(6,'Data-Related Roles'),(7,'Artificial Intelligence & Machine Learning'),(8,'IoT & Robotics'),(9,'IT Management'),(10,'Other Relevant Roles');
/*!40000 ALTER TABLE `position_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `skills`
--

DROP TABLE IF EXISTS `skills`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `skills` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `group` enum('PROGRAMMING_LANG','FRAMEWORK','LIBRARY','OTHER') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'OTHER',
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `skills`
--

LOCK TABLES `skills` WRITE;
/*!40000 ALTER TABLE `skills` DISABLE KEYS */;
INSERT INTO `skills` VALUES (1,'Golang','PROGRAMMING_LANG'),(2,'Python','PROGRAMMING_LANG'),(3,'NodeJS','PROGRAMMING_LANG'),(4,'Rust','PROGRAMMING_LANG'),(5,'Javascript','FRAMEWORK'),(6,'Typescript','PROGRAMMING_LANG'),(7,'CSS','PROGRAMMING_LANG'),(8,'C++','PROGRAMMING_LANG'),(9,'PHP','PROGRAMMING_LANG'),(10,'Tailwind','FRAMEWORK'),(11,'JAVA','PROGRAMMING_LANG'),(12,'OTHER','OTHER');
/*!40000 ALTER TABLE `skills` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `trending`
--

DROP TABLE IF EXISTS `trending`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `trending` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `level` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trending`
--

LOCK TABLES `trending` WRITE;
/*!40000 ALTER TABLE `trending` DISABLE KEYS */;
INSERT INTO `trending` VALUES (1,'PEAK',3),(2,'AVERAGE',2),(3,'WEAK',1);
/*!40000 ALTER TABLE `trending` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-06-16  7:31:50
