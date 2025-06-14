WebducationApi - Configuración de Base de Datos SQL Server
Autor: Jhonattan Halcón Casallas Felipe
Fecha de creación: 13/06/2025
Proyecto: WebducationApi (.NET 8)
Base de datos: SCHOOL_DB

🧾 Descripción del Proyecto
Este proyecto establece la estructura de base de datos y los procedimientos almacenados necesarios para gestionar el módulo educativo de estudiantes, profesores, cursos, calificaciones y usuarios. Se implementa un esquema llamado EDU en la base de datos SCHOOL_DB, y se brinda soporte para operaciones CRUD, especialmente sobre los estudiantes.

🚀 Estructura y Pasos de Ejecución
Sigue estos pasos en orden para configurar correctamente la base de datos SCHOOL_DB.

1️⃣ DDL - Creación de la Base de Datos y Tablas
Ejecuta este bloque SQL primero para crear la base de datos, el esquema y todas las tablas con sus relaciones (constraints).

-- Crear base de datos y esquema
CREATE DATABASE SCHOOL_DB;
GO

USE SCHOOL_DB;
GO

CREATE SCHEMA EDU;
GO

-- Crear tabla de estudiantes
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

-- Crear tabla de profesores
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

-- Crear tabla de cursos
CREATE TABLE [EDU].[Courses] (
    CourseId INT PRIMARY KEY IDENTITY(1,1),
    CourseName NVARCHAR(150) NOT NULL,
    Credits INT NOT NULL,
    TeacherId INT,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    CreatedBy NVARCHAR(100),
    UpdatedAt DATETIME,
    UpdatedBy NVARCHAR(100)
);

-- Crear tabla de calificaciones
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

-- Crear tabla de usuarios (para autenticación)
CREATE TABLE [EDU].[Users] (
    UserId INT IDENTITY(1,1) PRIMARY KEY,
    UserName NVARCHAR(100) NOT NULL UNIQUE,
    UserPasswordHash NVARCHAR(255) NOT NULL
);

-- Relaciones (Constraints)
ALTER TABLE [EDU].[Courses]
ADD CONSTRAINT FK_Courses_Teachers FOREIGN KEY (TeacherId)
REFERENCES [EDU].[Teachers](TeacherId);

ALTER TABLE [EDU].[Grades]
ADD CONSTRAINT FK_Grades_Students FOREIGN KEY (StudentId)
REFERENCES [EDU].[Students](StudentId);

ALTER TABLE [EDU].[Grades]
ADD CONSTRAINT FK_Grades_Courses FOREIGN KEY (CourseId)
REFERENCES [EDU].[Courses](CourseId);

-- Validación de rango para calificaciones
ALTER TABLE [EDU].[Grades]
ADD CONSTRAINT CK_Grades_Range CHECK (Grade BETWEEN 0 AND 100);

2️⃣ DML - Inserción de Datos Iniciales
Ejecuta este bloque para insertar datos de prueba en la tabla de estudiantes.

-- Insertar estudiantes de prueba
INSERT INTO [EDU].[Students] (FirstName, LastName, DateOfBirth, Email, CreatedBy)
VALUES
('María', 'González', '2000-05-14', 'maria.gonzalez@example.com', 'admin'),
('Luis', 'Pérez', '1999-11-22', 'luis.perez@example.com', 'admin'),
('Ana', 'Ramírez', '2001-03-08', 'ana.ramirez@example.com', 'admin'),
('Carlos', 'Mendoza', '1998-07-30', 'carlos.mendoza@example.com', 'admin'),
('Laura', 'Torres', '2002-01-15', 'laura.torres@example.com', 'admin');

3️⃣ Stored Procedures - Gestión de Estudiantes
Estos procedimientos almacenados permiten realizar operaciones CRUD (Crear, Leer, Actualizar, Eliminar) sobre la tabla de estudiantes.

-- Obtener todos los estudiantes
CREATE PROCEDURE [EDU].[SP_GET_STUDENTS]
AS
BEGIN
    SELECT StudentId, FirstName, LastName, DateOfBirth, Email, CreatedAt, CreatedBy, UpdatedAt, UpdatedBy
    FROM [EDU].[Students];
END;
GO

-- Obtener estudiante por ID
CREATE PROCEDURE [EDU].[SP_GET_STUDENT_BY_ID]
    @StudentId INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM [EDU].[Students] WHERE StudentId = @StudentId)
    BEGIN
        RAISERROR('No student found with the specified StudentId.', 16, 1);
        RETURN;
    END

    SELECT StudentId, FirstName, LastName, DateOfBirth, Email, CreatedAt, CreatedBy, UpdatedAt, UpdatedBy
    FROM [EDU].[Students]
    WHERE StudentId = @StudentId;
END;
GO

-- Insertar nuevo estudiante con validaciones
CREATE PROCEDURE [EDU].[SP_INSERT_STUDENT]
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @DateOfBirth DATE,
    @Email NVARCHAR(150),
    @CreatedBy NVARCHAR(100),
    @UpdatedBy NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF @FirstName IS NULL OR LTRIM(RTRIM(@FirstName)) = ''
            OR @LastName IS NULL OR LTRIM(RTRIM(@LastName)) = ''
            OR @DateOfBirth IS NULL
            OR @Email IS NULL OR LTRIM(RTRIM(@Email)) = ''
            OR @CreatedBy IS NULL OR LTRIM(RTRIM(@CreatedBy)) = ''
            OR @UpdatedBy IS NULL OR LTRIM(RTRIM(@UpdatedBy)) = ''
        BEGIN
            RAISERROR('All required fields must be provided and cannot be empty.', 16, 1);
            ROLLBACK;
            RETURN;
        END

        IF @Email NOT LIKE '%@%.%' OR CHARINDEX(' ', @Email) > 0
        BEGIN
            RAISERROR('The email format is invalid.', 16, 1);
            ROLLBACK;
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM [EDU].[Students] WHERE Email = @Email)
        BEGIN
            RAISERROR('The email is already registered to another person.', 16, 1);
            ROLLBACK;
            RETURN;
        END

        IF @DateOfBirth NOT BETWEEN DATEADD(YEAR, -95, GETDATE()) AND DATEADD(YEAR, -2, GETDATE())
        BEGIN
            RAISERROR('User must be between 2 and 95 years old.', 16, 1);
            ROLLBACK;
            RETURN;
        END

        INSERT INTO [EDU].[Students] (
            FirstName, LastName, DateOfBirth, Email,
            CreatedAt, CreatedBy, UpdatedAt, UpdatedBy
        )
        VALUES (
            @FirstName, @LastName, @DateOfBirth, @Email,
            GETDATE(), @CreatedBy, GETDATE(), @UpdatedBy
        );

        COMMIT;
        SELECT SCOPE_IDENTITY() AS StudentId;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH
END;
GO

-- Actualizar estudiante con validaciones
CREATE PROCEDURE [EDU].[SP_UPDATE_STUDENT]
    @StudentId INT,
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @DateOfBirth DATE,
    @Email NVARCHAR(150),
    @UpdatedBy NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM [EDU].[Students] WHERE StudentId = @StudentId)
        BEGIN
            RAISERROR('No student found with the specified StudentId to update.', 16, 1);
            ROLLBACK;
            RETURN;
        END

        IF @FirstName IS NULL OR LTRIM(RTRIM(@FirstName)) = ''
            OR @LastName IS NULL OR LTRIM(RTRIM(@LastName)) = ''
            OR @DateOfBirth IS NULL
            OR @Email IS NULL OR LTRIM(RTRIM(@Email)) = ''
            OR @UpdatedBy IS NULL OR LTRIM(RTRIM(@UpdatedBy)) = ''
        BEGIN
            RAISERROR('All required fields must be provided and cannot be empty.', 16, 1);
            ROLLBACK;
            RETURN;
        END

        IF @Email NOT LIKE '%@%.%' OR CHARINDEX(' ', @Email) > 0
        BEGIN
            RAISERROR('The email format is invalid.', 16, 1);
            ROLLBACK;
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM [EDU].[Students] WHERE Email = @Email AND StudentId <> @StudentId)
        BEGIN
            RAISERROR('The email is already registered to another student.', 16, 1);
            ROLLBACK;
            RETURN;
        END

        IF @DateOfBirth NOT BETWEEN DATEADD(YEAR, -95, GETDATE()) AND DATEADD(YEAR, -2, GETDATE())
        BEGIN
            RAISERROR('Student must be between 2 and 95 years old.', 16, 1);
            ROLLBACK;
            RETURN;
        END

        UPDATE [EDU].[Students]
        SET
            FirstName = @FirstName,
            LastName = @LastName,
            DateOfBirth = @DateOfBirth,
            Email = @Email,
            UpdatedAt = GETDATE(),
            UpdatedBy = @UpdatedBy
        WHERE StudentId = @StudentId;

        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH
END;
GO

-- Eliminar estudiante
CREATE PROCEDURE [EDU].[SP_DELETE_STUDENT]
    @StudentId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM [EDU].[Students] WHERE StudentId = @StudentId)
        BEGIN
            RAISERROR('No student found with the specified StudentId to delete.', 16, 1);
            ROLLBACK;
            RETURN;
        END

        DELETE FROM [EDU].[Students]
        WHERE StudentId = @StudentId;

        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH
END;
GO

🔗 Conexión de la API .NET a la Base de Datos
Para que tu aplicación .NET (WebducationApi) se conecte a la base de datos SCHOOL_DB, necesitas configurar la cadena de conexión en el archivo appsettings.json o appsettings.Development.json de tu proyecto.

Configuración en appsettings.json
Abre el archivo appsettings.json (o appsettings.Development.json si estás depurando) en tu proyecto WebducationApi y añade o modifica la sección ConnectionStrings de la siguiente manera:

{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=SCHOOL_DB;Trusted_Connection=True;MultipleActiveResultSets=true;TrustServerCertificate=True"
    // Asegúrate de que "localhost\\SQLEXPRESS" coincida con la instancia de tu SQL Server.
    // Si no usas una instancia nombrada, solo usa "Server=localhost;"
  }
}

Consideraciones sobre la cadena de conexión:

Server: Reemplaza localhost\\SQLEXPRESS con el nombre de tu servidor SQL Server o la instancia nombrada. Si tu SQL Server no tiene una instancia nombrada y es la instalación por defecto, puedes usar localhost o . (punto).

Database: Asegúrate de que sea SCHOOL_DB, el nombre de la base de datos que acabas de crear.

Trusted_Connection=True: Si estás usando autenticación de Windows (Windows Authentication) para conectarte a SQL Server, mantén esto como True.

User ID=your_username;Password=your_password: Si usas autenticación de SQL Server, reemplaza Trusted_Connection=True con User ID y Password.

TrustServerCertificate=True: Esto es necesario si estás utilizando certificados autofirmados (común en entornos de desarrollo). En producción, se recomienda configurar SSL/TLS correctamente.

⚠️ Recomendaciones
Utiliza SQL Server Management Studio (SSMS) o Azure Data Studio para ejecutar los scripts SQL.

Ejecuta los scripts paso a paso, siguiendo el orden presentado: 1 - DDL, 2 - DML, 3 - Procedimientos Almacenados.

No modifiques los nombres de columnas, procedimientos o esquemas sin actualizar también la lógica correspondiente en el backend de la API.

Asegúrate de que tu SQL Server esté en ejecución antes de intentar conectar la API.

Verifica que no haya problemas de firewall bloqueando la conexión al puerto de SQL Server (por defecto 1433).

✅ Resultado Esperado
Base de datos SCHOOL_DB con el esquema EDU correctamente creado y funcional.

Tablas Students, Teachers, Courses, Grades y Users correctamente definidas y relacionadas.

Datos de prueba insertados en la tabla Students.

Procedimientos almacenados para la gestión de estudiantes (SP_GET_STUDENTS, SP_GET_STUDENT_BY_ID, SP_INSERT_STUDENT, SP_UPDATE_STUDENT, SP_DELETE_STUDENT) activos y listos para ser consumidos desde tu aplicación WebducationApi en .NET 8.
