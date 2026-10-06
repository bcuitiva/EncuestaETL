

/* ---------------------------------------------------------------------
   BASE DE DATOS
   --------------------------------------------------------------------- */
IF DB_ID('EncuestaETL') IS NULL
    CREATE DATABASE EncuestaETL;
GO
USE EncuestaETL;
GO

/* ---------------------------------------------------------------------
   STAGING: copia cruda del Excel.
   --------------------------------------------------------------------- */
IF OBJECT_ID('dbo.stg_Personas') IS NOT NULL DROP TABLE dbo.stg_Personas;
CREATE TABLE dbo.stg_Personas (
    SourceRowId           NVARCHAR(255),
    DocumentType          NVARCHAR(255),
    DocumentNumber        NVARCHAR(255),
    FirstName             NVARCHAR(255),
    MiddleName            NVARCHAR(255),
    LastName              NVARCHAR(255),
    SecondLastName        NVARCHAR(255),
    BirthDate             NVARCHAR(255),
    ReportedAge           NVARCHAR(255),
    Sex                   NVARCHAR(255),
    MaritalStatus         NVARCHAR(255),
    Email                 NVARCHAR(255),
    Phone                 NVARCHAR(255),
    DepartmentCode        NVARCHAR(255),
    DepartmentName        NVARCHAR(255),
    MunicipalityCode      NVARCHAR(255),
    MunicipalityName      NVARCHAR(255),
    Zone                  NVARCHAR(255),
    Address               NVARCHAR(255),
    HousingType           NVARCHAR(255),
    SocioeconomicStratum  NVARCHAR(255),
    EducationLevel        NVARCHAR(255),
    EmploymentStatus      NVARCHAR(255),
    OccupationCode        NVARCHAR(255),
    OccupationName        NVARCHAR(255),
    EmployerName          NVARCHAR(255),
    ContractType          NVARCHAR(255),
    EmploymentStartDate   NVARCHAR(255),
    MonthlyIncome         NVARCHAR(255),
    MonthlyExpenses       NVARCHAR(255),
    Dependents            NVARCHAR(255),
    HouseholdSize         NVARCHAR(255),
    HealthRegime          NVARCHAR(255),
    Disability            NVARCHAR(255),
    SurveyDate            NVARCHAR(255),
    UpdatedAt             NVARCHAR(255),
    SourceChannel         NVARCHAR(255)
);
GO
