CREATE DATABASE SCHOOL_DB
GO

USE SCHOOL_DB
GO

CREATE SCHEMA EDU
GO


-- Tabla: Students
CREATE TABLE [EDU].[Students] (
    StudentId INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(100) NOT NULL,
    LastName NVARCHAR(100) NOT NULL,
    DateOfBirth DATE NOT NULL,
    Email NVARCHAR(150) UNIQUE,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    CreatedBy NVARCHAR(100),
    UpdatedAt DATETIME,
    UpdatedBy NVARCHAR(100)
);

-- Tabla: Teachers
CREATE TABLE [EDU].[Teachers] (
    TeacherId INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(100) NOT NULL,
    LastName NVARCHAR(100) NOT NULL,
    SubjectArea NVARCHAR(100),
    Email NVARCHAR(150) UNIQUE,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    CreatedBy NVARCHAR(100),
    UpdatedAt DATETIME,
    UpdatedBy NVARCHAR(100)
);

-- Tabla: Courses
CREATE TABLE [EDU].[Courses] (
    CourseId INT PRIMARY KEY IDENTITY(1,1),
    CourseName NVARCHAR(150) NOT NULL,
    Credits INT NOT NULL,
    TeacherId INT, -- Constraint se agrega después
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    CreatedBy NVARCHAR(100),
    UpdatedAt DATETIME,
    UpdatedBy NVARCHAR(100)
);

-- Tabla: Grades
CREATE TABLE [EDU].[Grades] (
    GradeId INT PRIMARY KEY IDENTITY(1,1),
    StudentId INT,
    CourseId INT,
    Grade DECIMAL(4,2) NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    CreatedBy NVARCHAR(100),
    UpdatedAt DATETIME,
    UpdatedBy NVARCHAR(100)
);


CREATE TABLE [EDU].[Users] (
    UserId INT IDENTITY(1,1) PRIMARY KEY,
    UserName NVARCHAR(100) NOT NULL UNIQUE,
    UserPasswordHash NVARCHAR(255) NOT NULL
);


-- Asignación de los constrains 
ALTER TABLE [EDU].[Courses]
ADD CONSTRAINT FK_Courses_Teachers
FOREIGN KEY (TeacherId) REFERENCES [EDU].[Teachers](TeacherId);

ALTER TABLE [EDU].[Grades]
ADD CONSTRAINT FK_Grades_Students
FOREIGN KEY (StudentId) REFERENCES [EDU].[Students](StudentId);

ALTER TABLE [EDU].[Grades]
ADD CONSTRAINT FK_Grades_Courses
FOREIGN KEY (CourseId) REFERENCES [EDU].[Courses](CourseId);

-- Validaciones (CHECK)
ALTER TABLE [EDU].[Grades]
ADD CONSTRAINT CK_Grades_Range
CHECK (Grade BETWEEN 0 AND 100);


