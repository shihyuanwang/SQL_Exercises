-- Shih-Yuan Wang
/********************************************
General tips for getting the highest score

Ensure the entire script can run from beginning to end without errors. If you cannot fully implement a PART or some statements, add what works correctly, and add comments to describe the issue. If you can't get a statement to process correctly, comment it out and add comments to explain the issue.
Again, the entire script needs to run without errors.

Every time a CREATE (Table, Index, Database, Stored Procedure, Trigger) is used ensure it has a corresponding DROP IF EXISTS that precedes it. This allows the script to be run over and over getting in an inconsistent state (e.g. remanent objects)
See the CREATE database section below as an example for a CREATE DATABASE statement, you'll need to do this for EVERY object  (Table, Index, Database, Stored Procedure, Trigger) you create.

For many batch statements, you'll need to use a GO as a separator, which resets the transaction block,otherwise you'll get an error.
As an example, make sure your DROP statements that preceed a CREATE of the same object have a GO in between

DROP statement <OBJECTA>
--followed by a
GO
--followed by a
CREATE statement <OBJECTA>

Without the GO, you'll get a Error like .....CREATE ....' must be the first statement in a query batch

Also, while not absolute, the same type of error CAN happen after a CREATE statement followed directly by a corresponding SELECT statement of the same object. (e.g. Create VIEW followed by a GO, then by a SELECT from the VIEW).
To be safe in this project, follow this pattern when you have the two statements back to back.
CREATE statement <OBJECTA>
--followed by a
GO
--followed by a
SELECT statement <OBJECTA>

********************************************/

/********************************************
PART A

CREATE DATABASE

To house the project, create a database : schooldb, so the script can be run over and over, use :

DROP DATABASE IF EXISTS schooldb statement before the  CREATE statement.

Don’t forget to specify USE schooldb once the db is created.
********************************************/
USE Master;
GO
DROP DATABASE IF EXISTS schooldb;
GO
CREATE DATABASE schooldb;
GO
USE schooldb;
PRINT 'Part A Completed'

-- ****************************
-- PART B - Define and execute usp_dropTables
-- ****************************
-- Create a Stored Procedure : usp_dropTables

DROP PROCEDURE IF EXISTS usp_dropTables
Go

CREATE PROCEDURE usp_dropTables AS
BEGIN
	DROP TABLE IF EXISTS StudentContacts
	DROP TABLE IF EXISTS Student_Courses
	DROP TABLE IF EXISTS Employees	
	DROP TABLE IF EXISTS EmpJobPosition	
	DROP TABLE IF EXISTS StudentInformation	
	DROP TABLE IF EXISTS CourseList	
	DROP TABLE IF EXISTS ContactType		 
END;
Go

-- Execute the stored procedure
Exec usp_dropTables

PRINT 'Part B Completed'

-- ****************************
-- PART C - Define and create the tables from the Entity Relationship Diagram
-- ****************************
-- ContactType  
CREATE TABLE ContactType (
ContactTypeID int identity(1,1) PRIMARY KEY, 
ContactType char(50) NOT NULL
)
Go

-- EmpJobPosition
CREATE TABLE EmpJobPosition(
EmpJobPositionID int identity(1,1) PRIMARY KEY,
EmployeePosition char(50) NOT NULL
)
Go

-- CourseList
CREATE TABLE CourseList(
CourseID int identity(10,1) PRIMARY KEY,
CourseDescription char(100) NOT NULL,
CourseCost decimal(10,2) NULL,
CourseDurationYears char(50) NULL,
Notes char(100) NULL
)
Go

-- StudentInformation
CREATE TABLE StudentInformation(
StudentID int identity(100,1) PRIMARY KEY,
Title char(50) NULL,
FirstName char(20) NOT NULL,
LastName char(20) NOT NULL,
Address1 char(50) NULL,
Address2 char(50) NULL,
City char(50) NULL,
County char(50) NULL,
Zip char(10) NULL,
Country char(50) NULL,
Telephone char(50) NULL,
Email char(100) NULL,
Enrolled char(50) NULL,
AltTelephone char(50) NULL
)
Go

-- Student_Courses
CREATE TABLE Student_Courses(
StudentCourseID int identity(1,1) PRIMARY KEY,
StudentID int NOT NULL FOREIGN KEY REFERENCES StudentInformation(StudentID),
CourseID int NOT NULL FOREIGN KEY REFERENCES CourseList(CourseID),
CourseStartDate date NOT NULL,
CourseComplete date NULL
)
Go

-- Employees
CREATE TABLE Employees(
EmployeeID int identity(1000,1) PRIMARY KEY,
EmployeeName char(50) NOT NULL,
EmployeePositionID int NOT NULL FOREIGN KEY REFERENCES EmpJobPosition(EmpJobPositionID),
EmployeePassword char(50) NULL,
Access char(50) NULL
)
Go

-- StudentContacts
CREATE TABLE StudentContacts(
ContactID int identity(10000,1) PRIMARY KEY,
StudentID int NOT NULL FOREIGN KEY REFERENCES StudentInformation(StudentID),
ContactTypeID int NOT NULL FOREIGN KEY REFERENCES ContactType(ContactTypeID),
ContactDate date NOT NULL,
EmployeeID int NOT NULL FOREIGN KEY REFERENCES Employees(EmployeeID),
ContactDetails char(100) NOT NULL
)
Go

PRINT 'Part C Completed'

-- ****************************
-- PART D - Adding columns, constraints, and indexes 
-- ****************************
-- Prevent duplicate records in Student_Courses
ALTER TABLE Student_Courses
ADD CONSTRAINT AK_Student_Course UNIQUE (StudentID, CourseID);
Go

-- Add a new column to the StudentInformation table called CreatedDateTime
ALTER TABLE StudentInformation
ADD CreatedDateTime datetime
Go

ALTER TABLE StudentInformation
ADD DEFAULT GETDATE() FOR CreatedDateTime
Go
-- Remove the AltTelephone column from the StudentInformation table
ALTER TABLE  StudentInformation
DROP COLUMN AltTelephone
Go

-- Add an Index called IX_LastName on the StudentInformation table
DROP INDEX IF EXISTS StudentInformation.IX_LastName
Go

CREATE INDEX IX_LastName
ON StudentInformation (LastName);
Go

PRINT 'Part D Completed'

-- ****************************
-- PART E - Create and apply a Trigger called trg_assignEmail 
-- ****************************
-- Create a trigger on the StudentInformation table : trg_assignEmail
DROP TRIGGER IF EXISTS trg_assignEmail
Go

CREATE TRIGGER trg_assignEmail ON StudentInformation
AFTER INSERT
AS
BEGIN
	DECLARE @firstName char(20);
	DECLARE @lastName char(20);
	DECLARE @Email char(100);
	set @firstName = (select FirstName from inserted)
	set @lastName = (select LastName from inserted)
	set @Email = (select Email from inserted)
	
	If @Email is NULL
		update StudentInformation
		set Email = (trim(@firstName) + '.' + trim(@lastName) + '@disney.com') 
		where StudentID = (select StudentID from inserted)
END
Go

--Test
/*
Delete from StudentInformation
INSERT INTO StudentInformation (FirstName,LastName,Email) VALUES ('Porky','Pig','porky.pig@warnerbros.com');
INSERT INTO StudentInformation (FirstName,LastName) VALUES ('Snow', 'White');
select * from StudentInformation
*/
PRINT 'Part E Completed'

-- ****************************
-- Part F
-- DATA Population
-- If the table structures have been created correct, these data population statements will run without issue
-- ****************************
-- Uncomment once Part B & C are created
INSERT INTO StudentInformation
   (FirstName,LastName)
VALUES
   ('Mickey', 'Mouse');

INSERT INTO StudentInformation
   (FirstName,LastName)
VALUES
   ('Minnie', 'Mouse');

INSERT INTO StudentInformation
   (FirstName,LastName)
VALUES
   ('Donald', 'Duck');

--SELECT * FROM StudentInformation;
---------
INSERT INTO CourseList
   (CourseDescription)
VALUES
   ('Advanced Math');

INSERT INTO CourseList
   (CourseDescription)
VALUES
   ('Intermediate Math');

INSERT INTO CourseList
   (CourseDescription)
VALUES
   ('Beginning Computer Science');

INSERT INTO CourseList
   (CourseDescription)
VALUES
   ('Advanced Computer Science');

--select * from CourseList;
---------
INSERT INTO Student_Courses
   (StudentID,CourseID,CourseStartDate)
VALUES
   (100, 10, '01/05/2018');

INSERT INTO Student_Courses
   (StudentID,CourseID,CourseStartDate)
VALUES
   (101, 11, '01/05/2018');

INSERT INTO Student_Courses
   (StudentID,CourseID,CourseStartDate)
VALUES
   (102, 11, '01/05/2018');
INSERT INTO Student_Courses
   (StudentID,CourseID,CourseStartDate)
VALUES
   (100, 11, '01/05/2018');

INSERT INTO Student_Courses
   (StudentID,CourseID,CourseStartDate)
VALUES
   (102, 13, '01/05/2018');

--select * from Student_Courses;
---------
INSERT INTO EmpJobPosition
   (EmployeePosition)
VALUES
   ('Math Instructor');

INSERT INTO EmpJobPosition
   (EmployeePosition)
VALUES
   ('Computer Science');

--select * from EmpJobPosition
---------
INSERT INTO Employees
   (EmployeeName,EmployeePositionID)
VALUES
   ('Walt Disney', 1);

INSERT INTO Employees
   (EmployeeName,EmployeePositionID)
VALUES
   ('John Lasseter', 2);

INSERT INTO Employees
   (EmployeeName,EmployeePositionID)
VALUES
   ('Danny Hillis', 2);
   
--select * from Employees;
---------
INSERT INTO ContactType
   (ContactType)
VALUES
   ('Tutor');

INSERT INTO ContactType
   (ContactType)
VALUES
   ('Homework Support');

INSERT INTO ContactType
   (ContactType)
VALUES
   ('Conference');

--SELECT * from ContactType;
---------

INSERT INTO StudentContacts
   (StudentID,ContactTypeID,EmployeeID,ContactDate,ContactDetails)
VALUES
   (100, 1, 1000, '11/15/2017', 'Micky and Walt Math Tutoring');

INSERT INTO StudentContacts
   (StudentID,ContactTypeID,EmployeeID,ContactDate,ContactDetails)
VALUES
   (101, 2, 1001, '11/18/2017', 'Minnie and John Homework support');

INSERT INTO StudentContacts
   (StudentID,ContactTypeID,EmployeeID,ContactDate,ContactDetails)
VALUES
   (100, 3, 1001, '11/18/2017', 'Micky and Walt Conference');

INSERT INTO StudentContacts
   (StudentID,ContactTypeID,EmployeeID,ContactDate,ContactDetails)
VALUES
   (102, 2, 1002, '11/20/2017', 'Donald and Danny Homework support');

--SELECT * from StudentContacts;
---------

-- Note for Part E, use these two inserts as examples to test the trigger
-- They will also be needed if you’re using the examples for Part G
INSERT INTO StudentInformation
   (FirstName,LastName,Email)
VALUES
   ('Porky', 'Pig', 'porky.pig@warnerbros.com');
INSERT INTO StudentInformation
   (FirstName,LastName)
VALUES
   ('Snow', 'White');

--select * from StudentInformation

PRINT 'Part F Completed'

-- ****************************
-- PART G - Create and execute usp_addQuickContacts 
-- ****************************
-- Write statements below 
DROP PROCEDURE IF EXISTS  usp_addQuickContacts
Go

CREATE PROCEDURE usp_addQuickContacts
@StudentEmail char(100),
@EmployeeName char(50),
@contactDetails char(100),
@contactType char(50)
AS

IF NOT EXISTS (select ContactType from ContactType where ContactType= @contactType) 
Begin
	--first inserted as an additional contactType 
	INSERT INTO ContactType(ContactType)
	VALUES(@contactType)
End	
--INSERT into the StudentContacts
DECLARE @StudentID int;
DECLARE @EmployeeID int;
DECLARE @ContactTypeID int;
set @StudentID = (select StudentID from StudentInformation where Email = @StudentEmail)
set @EmployeeID = (select EmployeeID from Employees where EmployeeName = @EmployeeName )
set @ContactTypeID = (select ContactTypeID from ContactType where ContactType = @contactType )

INSERT INTO StudentContacts(StudentID, ContactTypeID, ContactDate, EmployeeID, ContactDetails)
VALUES(@StudentID, @ContactTypeID, GETDATE(), @EmployeeID, @contactDetails)
Go

--Test
/*
EXEC usp_addQuickContacts 'minnie.mouse@disney.com','John Lasseter','Minnie getting Homework Support from John','Homework Support' 
EXEC usp_addQuickContacts 'porky.pig@warnerbros.com','John Lasseter','Porky studying with John for Test prep','Test Prep'
select * from ContactType
select * from StudentContacts
*/

PRINT 'Part G Completed'

-- ****************************
-- PART H - Create and execute usp_getCourseRosterByName 
-- ****************************
-- Write statements below 
DROP PROCEDURE IF EXISTS usp_getCourseRosterByName 
Go

CREATE PROCEDURE usp_getCourseRosterByName 
@CourseDescription char(100)
AS
select cl.CourseDescription, si.FirstName, si.LastName
from CourseList cl join Student_Courses sc on cl.CourseID = sc.CourseID
join StudentInformation si on sc.StudentID = si.StudentID
where cl.CourseDescription = @CourseDescription
Go

--Test
--EXEC usp_getCourseRosterByName 'Intermediate Math';

PRINT 'Part H Completed'

-- ****************************
-- Part I - Create and Select from vtutorContacts View 
-- ****************************

DROP VIEW IF EXISTS vtutorContacts
Go

CREATE VIEW vtutorContacts 
AS
SELECT e.EmployeeName, Trim(si.FirstName)+ ' ' + Trim(si.LastName) AS StudentName, sc.ContactDetails, sc.ContactDate
FROM StudentContacts sc join Employees e on sc.EmployeeID = e.EmployeeID
join StudentInformation si on sc.StudentID = si.StudentID
join ContactType ct on sc.ContactTypeID = ct.ContactTypeID
where ct.ContactType = 'Tutor'
Go
--select * from vtutorContacts

PRINT 'Part I Completed'


