---------------- STORED PROCEDURES  -- Courses --------------------

-- CREATED BY: FalconFelipe
-- PROJECT: WebducationApi
-- CREATION-DATE: 13/06/2025
-- DESCRIPTION: Stored procedures for managing CRUD operations for courses.

------------------------------------------------------

-- Obtener todos los cursos, con información del docente asociado.
CREATE PROCEDURE [EDU].[SP_GET_COURSES]
AS
BEGIN
    SELECT
        C.CourseId,
        C.CourseName,
        C.Credits,
        C.TeacherId,
        T.FirstName AS TeacherFirstName,
        T.LastName AS TeacherLastName,
        C.CreatedAt,
        C.CreatedBy,
        C.UpdatedAt,
        C.UpdatedBy
    FROM [EDU].[Courses] AS C
    INNER JOIN [EDU].[Teachers] AS T ON C.TeacherId = T.TeacherId;
END;
GO

-- Obtener un curso específico por su ID, incluyendo información del docente.
CREATE PROCEDURE [EDU].[SP_GET_COURSE_BY_ID]
    @CourseId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar si el curso existe.
    IF NOT EXISTS (SELECT 1 FROM [EDU].[Courses] WHERE CourseId = @CourseId)
    BEGIN
        RAISERROR('No course found with the specified CourseId.', 16, 1);
        RETURN;
    END

    SELECT
        C.CourseId,
        C.CourseName,
        C.Credits,
        C.TeacherId,
        T.FirstName AS TeacherFirstName,
        T.LastName AS TeacherLastName,
        C.CreatedAt,
        C.CreatedBy,
        C.UpdatedAt,
        C.UpdatedBy
    FROM [EDU].[Courses] AS C
    INNER JOIN [EDU].[Teachers] AS T ON C.TeacherId = T.TeacherId
    WHERE C.CourseId = @CourseId;
END;
GO

-- Insertar un nuevo curso.
CREATE PROCEDURE [EDU].[SP_INSERT_COURSE]
    @CourseName NVARCHAR(100),
    @Credits INT,
    @TeacherId INT,
    @CreatedBy NVARCHAR(100),
    @UpdatedBy NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que todos los campos requeridos no sean nulos o vacíos.
        IF @CourseName IS NULL OR LTRIM(RTRIM(@CourseName)) = ''
            OR @Credits IS NULL
            OR @TeacherId IS NULL
            OR @CreatedBy IS NULL OR LTRIM(RTRIM(@CreatedBy)) = ''
            OR @UpdatedBy IS NULL OR LTRIM(RTRIM(@UpdatedBy)) = ''
        BEGIN
            RAISERROR('All required fields must be provided and cannot be empty.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validar que el TeacherId especificado exista en la tabla Teachers.
        IF NOT EXISTS (SELECT 1 FROM [EDU].[Teachers] WHERE TeacherId = @TeacherId)
        BEGIN
            RAISERROR('The specified TeacherId does not exist.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Insertar el nuevo registro de curso.
        INSERT INTO [EDU].[Courses] (
            CourseName,
            Credits,
            TeacherId,
            CreatedAt,
            CreatedBy,
            UpdatedAt,
            UpdatedBy
        )
        VALUES (
            @CourseName,
            @Credits,
            @TeacherId,
            GETDATE(), -- Se establece la fecha de creación actual.
            @CreatedBy,
            GETDATE(), -- Se establece la fecha de actualización actual.
            @UpdatedBy
        );

        -- Obtener el ID del curso recién insertado.
        DECLARE @NewCourseId INT = SCOPE_IDENTITY();

        COMMIT TRANSACTION; -- Confirmar la transacción.

        SELECT @NewCourseId AS CourseId; -- Devolver el ID del curso creado.
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION; -- Revertir la transacción en caso de error.
        THROW; -- Relanzar la excepción.
    END CATCH
END;
GO

-- Actualizar un curso existente.
CREATE PROCEDURE [EDU].[SP_UPDATE_COURSE]
    @CourseId INT,
    @CourseName NVARCHAR(100),
    @Credits INT,
    @TeacherId INT,
    @UpdatedBy NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que todos los campos obligatorios no sean nulos o vacíos.
        IF @CourseId IS NULL
            OR @CourseName IS NULL OR LTRIM(RTRIM(@CourseName)) = ''
            OR @Credits IS NULL
            OR @TeacherId IS NULL
            OR @UpdatedBy IS NULL OR LTRIM(RTRIM(@UpdatedBy)) = ''
        BEGIN
            RAISERROR('All required fields must be provided and cannot be empty.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validar que el curso a actualizar exista.
        IF NOT EXISTS (SELECT 1 FROM [EDU].[Courses] WHERE CourseId = @CourseId)
        BEGIN
            RAISERROR('Course not found.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validar que el TeacherId especificado exista.
        IF NOT EXISTS (SELECT 1 FROM [EDU].[Teachers] WHERE TeacherId = @TeacherId)
        BEGIN
            RAISERROR('The specified TeacherId does not exist.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Actualizar el registro del curso.
        UPDATE [EDU].[Courses]
        SET
            CourseName = @CourseName,
            Credits = @Credits,
            TeacherId = @TeacherId,
            UpdatedAt = GETDATE(), -- Se actualiza la fecha de actualización.
            UpdatedBy = @UpdatedBy
        WHERE CourseId = @CourseId;

        COMMIT TRANSACTION; -- Confirmar la transacción.

        SELECT @CourseId AS CourseId; -- Devolver el ID del curso actualizado.
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION; -- Revertir la transacción en caso de error.
        THROW; -- Relanzar la excepción.
    END CATCH
END;
GO

-- Eliminar un curso por su ID.
CREATE PROCEDURE [EDU].[SP_DELETE_COURSE]
    @CourseId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Validar si el curso a eliminar existe.
        IF NOT EXISTS (SELECT 1 FROM [EDU].[Courses] WHERE CourseId = @CourseId)
        BEGIN
            RAISERROR('No course found with the specified CourseId.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Eliminar el registro del curso.
        DELETE FROM [EDU].[Courses] WHERE CourseId = @CourseId;

        -- Validar si la eliminación fue exitosa.
        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR('Failed to delete the course. No records were removed.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        COMMIT TRANSACTION; -- Confirmar la transacción.

        SELECT 1 AS Status; -- Devolver un estado de éxito (1).
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION; -- Revertir la transacción en caso de error.
        THROW; -- Relanzar la excepción.
    END CATCH
END;
GO
