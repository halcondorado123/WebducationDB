---------------- STORED PROCEDURES  -- Teachers --------------------

-- NOTA: Copie, pegue y ejecute este script en su gestor de bases de datos (preferiblemente SQL Server).
-- Asegúrese de ajustar la sintaxis según sea necesario, sin modificar los valores de las columnas.
-- Ejecturar estos procedimientos luego de ejecutar los procedimientos del paso número 3
-- 03_STORED_PROCEDURES.sql

-------------- CREATION INFORMATION -------------------

-- CREATED BY: JHONATTAN HALCON CASALLAS FELIPE
-- PROJECT: WebducationApi
-- CREATION-DATE: 14/06/2025
-- DESCRPTION: Procedimientos almacenados responsables de gestionar el proceso CRUD para el control de docentes, brindando soporte a la ejecución del proyecto desarrollado en .NET 8.

------------------------------------------------------

-- Obtener todos los docentes
CREATE PROCEDURE [EDU].[SP_GET_TEACHERS]
AS
BEGIN
    SELECT
		TEA.TeacherId,
		TEA.FirstName,
		TEA.LastName,
		TEA.SubjectArea,
		TEA.Email,
		TEA.CreatedAt,
		TEA.CreatedBy,
		TEA.UpdatedAt,
		TEA.UpdatedBy
	FROM [EDU].[Teachers] AS TEA
END;
GO

-- Obtener docente por ID de los registros
CREATE PROCEDURE [EDU].[SP_GET_TEACHER_BY_ID]
    @TeacherId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si el docente existe
    IF NOT EXISTS (SELECT 1 FROM [EDU].[Teachers] WHERE TeacherId = @TeacherId)
    BEGIN
        RAISERROR('No teacher found with the specified TeacherId.', 16, 1);
        RETURN;
    END

    -- Si el docente existe, devolver sus datos
		SELECT
				TEA.TeacherId,
				TEA.FirstName,
				TEA.LastName,
				TEA.SubjectArea,
				TEA.Email,
				TEA.CreatedAt,
				TEA.CreatedBy,
				TEA.UpdatedAt,
				TEA.UpdatedBy
			FROM [EDU].[Teachers] AS TEA
			WHERE TEA.TeacherId = @TeacherId;
END;
GO

-- Crear registro de nuevo docente
CREATE PROCEDURE [EDU].[SP_INSERT_TEACHER]
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @SubjectArea NVARCHAR(100), -- Nuevo campo
    @Email NVARCHAR(150),
    @CreatedBy NVARCHAR(100),
    @UpdatedBy NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validación de campos vacíos
        IF @FirstName IS NULL OR LTRIM(RTRIM(@FirstName)) = ''
            OR @LastName IS NULL OR LTRIM(RTRIM(@LastName)) = ''
            OR @Email IS NULL OR LTRIM(RTRIM(@Email)) = ''
            OR @CreatedBy IS NULL OR LTRIM(RTRIM(@CreatedBy)) = ''
            OR @UpdatedBy IS NULL OR LTRIM(RTRIM(@UpdatedBy)) = ''
        BEGIN
            RAISERROR('All required fields must be provided and cannot be empty.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validación de formato de email básico
        IF @Email NOT LIKE '%@%.%' OR CHARINDEX(' ', @Email) > 0
        BEGIN
            RAISERROR('The email format is invalid.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Valida si el correo ya existe para otro docente
        IF EXISTS (SELECT 1 FROM [EDU].[Teachers] WHERE Email = @Email)
        BEGIN
            RAISERROR('The email is already registered to another teacher.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Inserción del nuevo docente
        INSERT INTO [EDU].[Teachers] (
            FirstName,
            LastName,
            SubjectArea,
            Email,
            CreatedAt,
            CreatedBy,
            UpdatedAt,
            UpdatedBy
        )
        VALUES (
            @FirstName,
            @LastName,
            @SubjectArea,
            @Email,
            GETDATE(),
            @CreatedBy,
            GETDATE(),
            @UpdatedBy
        );

        DECLARE @NewTeacherId INT = SCOPE_IDENTITY();

        COMMIT TRANSACTION;

        SELECT @NewTeacherId AS TeacherId;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- Actualizar registro de docente en base de datos
CREATE PROCEDURE [EDU].[SP_UPDATE_TEACHER]
    @TeacherId INT,
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @SubjectArea NVARCHAR(100), -- Nuevo campo
    @Email NVARCHAR(150),
    @UpdatedBy NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validación: campos obligatorios no pueden ser nulos o vacíos
        IF @TeacherId IS NULL
            OR @FirstName IS NULL OR LTRIM(RTRIM(@FirstName)) = ''
            OR @LastName IS NULL OR LTRIM(RTRIM(@LastName)) = ''
            OR @Email IS NULL OR LTRIM(RTRIM(@Email)) = ''
            OR @UpdatedBy IS NULL OR LTRIM(RTRIM(@UpdatedBy)) = ''
        BEGIN
            RAISERROR('All required fields must be provided and cannot be empty.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validación de formato de email
        IF @Email NOT LIKE '%@%.%' OR CHARINDEX(' ', @Email) > 0
        BEGIN
            RAISERROR('The email format is invalid.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validación: el docente debe existir
        IF NOT EXISTS (SELECT 1 FROM [EDU].[Teachers] WHERE TeacherId = @TeacherId)
        BEGIN
            RAISERROR('Teacher not found.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validación: el nuevo correo no puede estar en uso por otro docente
        IF EXISTS (
            SELECT 1 FROM [EDU].[Teachers]
            WHERE Email = @Email AND TeacherId <> @TeacherId
        )
        BEGIN
            RAISERROR('The email is already registered to another teacher.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Actualización del docente
        UPDATE [EDU].[Teachers]
        SET
            FirstName = @FirstName,
            LastName = @LastName,
            SubjectArea = @SubjectArea,
            Email = @Email,
            UpdatedAt = GETDATE(),
            UpdatedBy = @UpdatedBy
        WHERE TeacherId = @TeacherId;

        COMMIT TRANSACTION;

        SELECT @TeacherId AS TeacherId; -- Confirmación del ID actualizado
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- Eliminar registro de la base de datos del docente registrado, devolviendo las filas afectadas
CREATE PROCEDURE [EDU].[SP_DELETE_TEACHER]
    @TeacherId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Verificar si el docente existe
        IF NOT EXISTS (SELECT 1 FROM [EDU].[Teachers] WHERE TeacherId = @TeacherId)
        BEGIN
            RAISERROR('No teacher found with the specified TeacherId.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Eliminar el docente
        DELETE FROM [EDU].[Teachers] WHERE TeacherId = @TeacherId;

        -- Validar si realmente se eliminó
        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR('Failed to delete the teacher. No records were removed.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        COMMIT TRANSACTION;

        SELECT 1 AS Status; -- Confirmación de eliminación
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
