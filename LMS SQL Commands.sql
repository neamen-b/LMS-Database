CREATE DATABASE Ellucian;
USE Ellucian;

-- Create a new table for students
CREATE TABLE Students (
    StudentID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    TotalCreditHours INT,
    GPA DECIMAL(3, 2)
); 

INSERT INTO Students (StudentID, FirstName, LastName, TotalCreditHours, GPA)
VALUES 
 ('10001', 'Sam', 'Carson', '12', '3.5'),
 ('10002', 'Rick', 'Astley', '21', '2.5'),
 ('10003','Daby','Balde', '56', '3.9'),
 ('10004', 'Uncle', 'Ruckus', '104', '2.0');


CREATE TABLE Professors (
    ProfessorID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Salary DECIMAL(10, 2)
);

CREATE TABLE Teachings (
    TeachingID INT PRIMARY KEY,
    ProfessorID INT,
    CourseID INT,
    FOREIGN KEY (ProfessorID) REFERENCES Professors(ProfessorID),
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID)
);

INSERT INTO Teachings (TeachingID, ProfessorID, CourseID)
VALUES 
       (10001, 1002, 1002),
       (10002, 1001,1001),
       (10003, 1003, 1003);

-- Insert three professors into the Professors table
INSERT INTO Professors (ProfessorID, FirstName, LastName, Salary)
VALUES
    ('1001','Professor Aquarius', 'Waterloo', 75000),
    ('1002','Dr. Pro. Crastinator', 'Psych', 80000),
    ('1003','Professor Zed', 'Survivor', 70000);

CREATE TABLE Courses (
    CourseID INT PRIMARY KEY,
    Department VARCHAR(50),
    CourseNumber VARCHAR(10),
    Section VARCHAR(10),
    CourseName VARCHAR(100),
    CreditHours INT,
    CourseDescription TEXT
);

INSERT INTO Courses (CourseID, Department, CourseNumber, Section, CourseName, CreditHours, CourseDescription)
VALUES
    ('1001', 'AquaStudies', 'AQUA101', 'U15', 'Water Weaving', 3, 'Master the art of basket weaving, underwater!'),
    ('1002', 'Psychology', 'PSYCH110', 'U18','Procrastination', 4, 'Learn to procrastinate like a pro and still succeed!'),
    ('1003', 'Survival', 'SURV101', 'U12','Zombie Survival', 2, 'Surviving the zombie apocalypse 101.'),
    ('1004', 'Culinary Arts', 'CULIN202', 'U23','Tasting and Testing', 3, 'Experience the delicate science of savoring food.'),
    ('1005', 'AstroStudies', 'ASTRO303', 'U23', 'Extraterrestil Life',5, 'Understanding the universe from an alien perspective.');


CREATE TABLE StudentCourses (
    StudentCourseID INT PRIMARY KEY,
    StudentID INT,
    CourseID INT,
    LetterGrade VARCHAR(2), -- letter grades like A, B, C, etc.
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID)
);

CREATE TABLE Enrollments (
    EnrollmentID INT PRIMARY KEY,
    StudentID INT,
    CourseID INT,
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID)
);

CREATE TABLE StudentGrades (
    GradeID INT PRIMARY KEY,
    EnrollmentID INT,
    FinalGrade VARCHAR(10),
    FOREIGN KEY (EnrollmentID) REFERENCES Enrollments(EnrollmentID)
);

INSERT INTO StudentGrades (GradeID, EnrollmentID, FinalGrade)
VALUES
	(101, 10002, 'B');
    
-- Question 1. Grant priviledges to user 
CREATE USER 'Gabriel'@'localhost' IDENTIFIED BY 'G19';
GRANT INSERT, DELETE, SELECT ON Ellucian.* TO 'Gabriel'@'localhost';

-- Question 2. Select all students who are registered in any course
SELECT Students.StudentID, Students.FirstName, Students.LastName
FROM Students
WHERE Students.StudentID IN (SELECT StudentID FROM Enrollments);

-- Question 3. Select the grade of a specific student on a previously taken course
SELECT Students.FirstName, Students.LastName, Courses.CourseName, StudentGrades.FinalGrade
FROM Students
JOIN Enrollments ON Students.StudentID = Enrollments.StudentID
JOIN Courses ON Enrollments.CourseID = Courses.CourseID
JOIN StudentGrades ON Enrollments.EnrollmentID = StudentGrades.EnrollmentID
WHERE Students.StudentID = 'YourStudentID' -- Replace 'YourStudentID' with the specific student's ID
  AND Courses.CourseName = 'YourCourseName'; -- Replace 'YourCourseName' with the specific course name
  
-- Question 4. Add/Enroll a student to a course
INSERT INTO Enrollments (EnrollmentID, StudentID, CourseID)
VALUES 
	('10001', '10004', '1003'),
	('10002', '10001','1002');

-- Question 5. Remove a student from a course without a W (Withdrawal)
SET @enrollmentID = (
SELECT EnrollmentID FROM Enrollments
WHERE StudentID = 'YourStudentID'
AND CourseID = 'YourCourseID'
);
DELETE FROM Enrollments 
WHERE EnrollmentID = @enrollmentID;


-- Question 6. Remove a student from a course with a W (Withdrawal)

SET @enrollmentID = (
SELECT EnrollmentID FROM Enrollments
WHERE StudentID = 'YourStudentID'
AND CourseID = 'YourCourseID'
);

UPDATE StudentGrades
SET FinalGrade = 'W'
WHERE EnrollmentID = @enrollmentID;

DELETE FROM Enrollments 
WHERE EnrollmentID = @enrollmentID;


-- Extra Credit 1
-- Updating the credits hours of student to the sum of credit hours od courses where they have passed
-- The passing grade is a letter grade of 'C' or higher
UPDATE Students
SET TotalCreditHours = (
    SELECT SUM(Courses.CreditHours)
    FROM Enrollments
    JOIN StudentGrades ON Enrollments.EnrollmentID = StudentGrades.EnrollmentID
    JOIN Courses ON Enrollments.CourseID = Courses.CourseID
    WHERE Enrollments.StudentID = Students.StudentID
    AND StudentGrades.FinalGrade >= 'C'
)
WHERE StudentID = 'YourStudentID';

select * from students;
-- Extra Credit 2
SELECT Courses.CourseName
FROM Students
JOIN Enrollments ON Students.StudentID = Enrollments.StudentID
JOIN Courses ON Enrollments.CourseID = Courses.CourseID
JOIN Teachings ON Courses.CourseID = Teachings.CourseID
WHERE Students.StudentID = 'YourStudentID' -- Replace 'YourStudentID' with the specific student's ID
  AND Teachings.ProfessorID = 'YourProfessorID'; -- Replace 'YourProfessorID' with the specific professor's ID
  






