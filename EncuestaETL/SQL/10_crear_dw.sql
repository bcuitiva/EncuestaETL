

IF DB_ID('EncuestaDW') IS NULL
    CREATE DATABASE EncuestaDW;
GO
USE EncuestaDW;
GO

/* ---------------------------------------------------------------------
   DIMENSIONES
   ...Key = clave sustituta (propia del DW)
   ...Id  = clave natural (la del modelo relacional), única -> se usa en el Lookup
   --------------------------------------------------------------------- */
CREATE TABLE dbo.DimTiempo (
    TiempoKey  INT  PRIMARY KEY,          -- AAAAMMDD, ej. 20250404
    Fecha      DATE NOT NULL UNIQUE,
    Anio       INT  NOT NULL,     -- INT para que coincida con el DT_I4 que
    Mes        INT  NOT NULL,     -- produce el Derived Column de SSIS
    Trimestre  INT  NOT NULL,
    Dia        INT  NOT NULL
);

CREATE TABLE dbo.DimUbicacion (
    UbicacionKey        INT IDENTITY PRIMARY KEY,
    MunicipioId         INT NOT NULL UNIQUE,
    CodigoMunicipio     NVARCHAR(5)  NOT NULL,
    Municipio           NVARCHAR(60) NOT NULL,
    CodigoDepartamento  NVARCHAR(5)  NOT NULL,
    Departamento        NVARCHAR(60) NOT NULL
);

CREATE TABLE dbo.DimEducacion (
    EducacionKey     INT IDENTITY PRIMARY KEY,
    NivelEducativoId INT NOT NULL UNIQUE,
    NivelEducativo   NVARCHAR(30) NOT NULL
);

CREATE TABLE dbo.DimSituacionLaboral (
    SituacionLaboralKey INT IDENTITY PRIMARY KEY,
    SituacionLaboralId  INT NOT NULL UNIQUE,
    SituacionLaboral    NVARCHAR(30) NOT NULL
);

CREATE TABLE dbo.DimPersona (
    PersonaKey      INT IDENTITY PRIMARY KEY,
    PersonaId       INT NOT NULL UNIQUE,
    TipoDocumento   NVARCHAR(5)  NOT NULL,
    NumeroDocumento NVARCHAR(10) NOT NULL,
    Sexo            NVARCHAR(2)  NULL
);

/* ---------------------------------------------------------------------
   HECHOS
   --------------------------------------------------------------------- */
CREATE TABLE dbo.FactObservacion (
    PersonaKey            INT NOT NULL REFERENCES dbo.DimPersona(PersonaKey),
    TiempoKey             INT NOT NULL REFERENCES dbo.DimTiempo(TiempoKey),
    UbicacionKey          INT NOT NULL REFERENCES dbo.DimUbicacion(UbicacionKey),
    EducacionKey          INT NOT NULL REFERENCES dbo.DimEducacion(EducacionKey),
    SituacionLaboralKey   INT NOT NULL REFERENCES dbo.DimSituacionLaboral(SituacionLaboralKey),
    IngresoMensual        DECIMAL(18,2) NULL,   -- NULL = desconocido
    GastoMensual          DECIMAL(18,2) NULL,
    BalanceMensual        DECIMAL(18,2) NULL,   -- NULL si falta ingreso o gasto
    CantidadObservaciones INT NOT NULL DEFAULT 1,
    CONSTRAINT PK_FactObservacion PRIMARY KEY (PersonaKey, TiempoKey)  -- = granularidad
);
GO
