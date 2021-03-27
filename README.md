# SQL Exercises

**1. Fiddle:** SQL Query Practice

http://sqlfiddle.com/#!9/54feb2/18\


**2. Project: Students, Courses, and Instructors Relational Database**

The following data model is designed to hold information relating to Students, Student Courses and Instructors who tutor students. 

For this scenario, we need to define the following entities:

- Student Information  
- Courses  
- Student Courses  (enrollment)
- Employees (instructors)  
- Student Contacts (Contact between the Student and the Instructor) 
- Contact Types (Tutor, Test support,etc..)


The entities are based on the ER diagram below and use the following rules to determine the table relationships. 

- A Student can enroll in one or many Courses 
- A Course can have one or many Students enrolled in it.  
- A Student can have zero, one, or many forms of contact with the Course Tutor  
- An Employee (Tutor) can have many contacts  
- A contact Type (Tutor, Test support,etc..) can have zero, one, or many contacts

The design allows ~
- a Student to enroll in one or multiple Courses, 
- a Course allowing one or more Students enrolled in it.
- a student may be in contact with the Course Tutor many times using many different forms of contact.  
- an instructor can connect with many contacts involving many Students
