---------------- STORED PROCEDURES  -- PersonME --------------------

-- NOTA: Copie, pegue y ejecute este script en su gestor de bases de datos (preferiblemente SQL Server). 
-- Aseg�rese de ajustar la sintaxis seg�n sea necesario, sin modificar los valores de las columnas.

-------------- CREATION INFORMATION -------------------

-- CREATED BY: JHONATTAN HALCON CASALLAS FELIPE
-- PROJECT: WebducationApi
-- CREATION-DATE: 13/06/2025
-- DESCRPTION: Procedimientos almacenados responsables de gestionar el proceso CRUD para el control de estudiantes y docentes, brindando soporte a la ejecuci�n del proyecto desarrollado en .NET 8.

------------------------------------------------------

-- Obtener todos las personas, se implementa uso de paginaci�n
CREATE PROCEDURE [EDU].[SP_GET_STUDENTS]
AS
BEGIN
    SELECT 
		PER.StudentId,
		PER.FirstName,
		PER.LastName,
		PER.DateOfBirth,
		PER.Email,
		PER.CreatedAt,
		PER.CreatedBy,
		PER.UpdatedAt,
		PER.UpdatedBy
	FROM [EDU].[Students] AS PER
END;
GO

-- Obtener persona por ID de los registros
CREATE PROCEDURE [EDU].[SP_GET_STUDENT_BY_ID]
    @StudentId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si la persona existe
    IF NOT EXISTS (SELECT 1 FROM [EDU].[Students] WHERE StudentId = @StudentId)
    BEGIN
        RAISERROR('No user found with the specified PersonId.', 16, 1);
        RETURN;
    END

    --  Si la persona existe, devolver sus datos
		SELECT 
				PER.StudentId,
				PER.FirstName,
				PER.LastName,
				PER.DateOfBirth,
				PER.Email,
				PER.CreatedAt,
				PER.CreatedBy,
				PER.UpdatedAt,
				PER.UpdatedBy
			FROM [EDU].[Students] AS PER
			WHERE PER.StudentId = @StudentId;
END;
GO


	
-- Crear registro de nuevo persona
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

        -- Validaci�n de campos vac�os
        IF @FirstName IS NULL OR LTRIM(RTRIM(@FirstName)) = ''
            OR @LastName IS NULL OR LTRIM(RTRIM(@LastName)) = ''
            OR @DateOfBirth IS NULL
            OR @Email IS NULL OR LTRIM(RTRIM(@Email)) = ''
            OR @CreatedBy IS NULL OR LTRIM(RTRIM(@CreatedBy)) = ''
            OR @UpdatedBy IS NULL OR LTRIM(RTRIM(@UpdatedBy)) = ''
        BEGIN
            RAISERROR('All required fields must be provided and cannot be empty.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validaci�n de formato de email b�sico
        IF @Email NOT LIKE '%@%.%' OR CHARINDEX(' ', @Email) > 0
        BEGIN
            RAISERROR('The email format is invalid.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Valida si el correo ya existe
        IF EXISTS (SELECT 1 FROM [EDU].[Students] WHERE Email = @Email)
        BEGIN
            RAISERROR('The email is already registered to another person.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validaci�n de edad entre 2 y 95 a�os
        IF @DateOfBirth NOT BETWEEN DATEADD(YEAR, -95, CAST(GETDATE() AS DATE)) AND DATEADD(YEAR, -2, CAST(GETDATE() AS DATE))
        BEGIN
            RAISERROR('User must be between 2 and 95 years old.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Inserci�n del nuevo estudiante
        INSERT INTO [EDU].[Students] (
            FirstName,
            LastName,
            DateOfBirth,
            Email,
            CreatedAt,
            CreatedBy,
            UpdatedAt,
            UpdatedBy
        )
        VALUES (
            @FirstName,
            @LastName,
            @DateOfBirth,
            @Email,
            GETDATE(),
            @CreatedBy,
            GETDATE(),
            @UpdatedBy
        );

        DECLARE @NewStudentId INT = SCOPE_IDENTITY();

        COMMIT TRANSACTION;

        SELECT @NewStudentId AS StudentId;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO



-- Actualizar registro de persona en base de datos
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

        -- Validaci�n: campos obligatorios no pueden ser nulos o vac�os
        IF @StudentId IS NULL
            OR @FirstName IS NULL OR LTRIM(RTRIM(@FirstName)) = ''
            OR @LastName IS NULL OR LTRIM(RTRIM(@LastName)) = ''
            OR @DateOfBirth IS NULL
            OR @Email IS NULL OR LTRIM(RTRIM(@Email)) = ''
            OR @UpdatedBy IS NULL OR LTRIM(RTRIM(@UpdatedBy)) = ''
        BEGIN
            RAISERROR('All required fields must be provided and cannot be empty.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validaci�n de formato de email
        IF @Email NOT LIKE '%@%.%' OR CHARINDEX(' ', @Email) > 0
        BEGIN
            RAISERROR('The email format is invalid.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validaci�n: el estudiante debe existir
        IF NOT EXISTS (SELECT 1 FROM [EDU].[Students] WHERE StudentId = @StudentId)
        BEGIN
            RAISERROR('Student not found.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validaci�n: el nuevo correo no puede estar en uso por otro estudiante
        IF EXISTS (
            SELECT 1 FROM [EDU].[Students]
            WHERE Email = @Email AND StudentId <> @StudentId
        )
        BEGIN
            RAISERROR('The email is already registered to another person.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validaci�n de rango de edad: entre 2 y 95 a�os
        IF @DateOfBirth NOT BETWEEN DATEADD(YEAR, -95, CAST(GETDATE() AS DATE)) AND DATEADD(YEAR, -2, CAST(GETDATE() AS DATE))
        BEGIN
            RAISERROR('User must be between 2 and 95 years old.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Actualizaci�n del estudiante
        UPDATE [EDU].[Students]
        SET
            FirstName = @FirstName,
            LastName = @LastName,
            DateOfBirth = @DateOfBirth,
            Email = @Email,
            UpdatedAt = GETDATE(),
            UpdatedBy = @UpdatedBy
        WHERE StudentId = @StudentId;

        COMMIT TRANSACTION;

        SELECT @StudentId AS StudentId; -- Confirmaci�n del ID actualizado
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO




-- Eliminar registro de la base de datos de la persona que estaba registrada, devolviendo las filas afectadas
CREATE PROCEDURE [EDU].[SP_DELETE_STUDENT]
    @StudentId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Verificar si el estudiante existe
        IF NOT EXISTS (SELECT 1 FROM [EDU].[Students] WHERE StudentId = @StudentId)
        BEGIN
            RAISERROR('No user found with the specified StudentId.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Eliminar el estudiante
        DELETE FROM [EDU].[Students] WHERE StudentId = @StudentId;

        -- Validar si realmente se elimin�
        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR('Failed to delete the user. No records were removed.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        COMMIT TRANSACTION;
        
        SELECT 1 AS Status; -- Confirmaci�n de eliminaci�n
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

