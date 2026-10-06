

USE EncuestaETL;
GO

CREATE TABLE dbo.TipoDocumento (
    TipoDocumentoId INT IDENTITY PRIMARY KEY,
    Codigo          NVARCHAR(5)  NOT NULL UNIQUE,
    Descripcion     NVARCHAR(50) NOT NULL
);

CREATE TABLE dbo.Departamento (
    DepartamentoId INT IDENTITY PRIMARY KEY,
    Codigo         NVARCHAR(5)  NOT NULL UNIQUE,
    Nombre         NVARCHAR(60) NOT NULL
);

CREATE TABLE dbo.Municipio (
    MunicipioId    INT IDENTITY PRIMARY KEY,
    Codigo         NVARCHAR(5)  NOT NULL UNIQUE,
    Nombre         NVARCHAR(60) NOT NULL,
    DepartamentoId INT NOT NULL REFERENCES dbo.Departamento(DepartamentoId)
);

CREATE TABLE dbo.NivelEducativo (
    NivelEducativoId INT IDENTITY PRIMARY KEY,
    Nombre           NVARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE dbo.SituacionLaboral (
    SituacionLaboralId INT IDENTITY PRIMARY KEY,
    Nombre             NVARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE dbo.Ocupacion (
    OcupacionId INT IDENTITY PRIMARY KEY,
    Codigo      NVARCHAR(5)  NOT NULL UNIQUE,
    Nombre      NVARCHAR(60) NOT NULL
);
GO

INSERT INTO dbo.TipoDocumento (Codigo, Descripcion) VALUES
 ('CC','CÉDULA DE CIUDADANÍA'), ('CE','CÉDULA DE EXTRANJERÍA'), ('PA','PASAPORTE');

INSERT INTO dbo.Departamento (Codigo, Nombre) VALUES
 ('D01','CUNDINAMARCA'), ('D02','BOGOTÁ D.C.'), ('D03','ANTIOQUIA'),
 ('D04','BOYACÁ'), ('D05','VALLE DEL CAUCA');

INSERT INTO dbo.Municipio (Codigo, Nombre, DepartamentoId)
SELECT v.Cod, v.Nom, d.DepartamentoId
FROM (VALUES
 ('M001','CHÍA','D01'), ('M002','CAJICÁ','D01'), ('M003','ZIPAQUIRÁ','D01'),
 ('M004','SOACHA','D01'), ('M005','BOGOTÁ D.C.','D02'), ('M006','MEDELLÍN','D03'),
 ('M007','ENVIGADO','D03'), ('M008','TUNJA','D04'), ('M009','DUITAMA','D04'),
 ('M010','CALI','D05')
) v(Cod, Nom, Dep)
JOIN dbo.Departamento d ON d.Codigo = v.Dep;
-- M999 'MUNICIPIO DESCONOCIDO' NO se crea: no es un municipio real; esos registros van a revisión.

INSERT INTO dbo.NivelEducativo (Nombre) VALUES
 ('NINGUNO'), ('PRIMARIA'), ('SECUNDARIA'), ('TECNICO'), ('TECNOLOGO'), ('UNIVERSITARIO'), ('POSGRADO');

INSERT INTO dbo.SituacionLaboral (Nombre) VALUES
 ('EMPLEADO'), ('INDEPENDIENTE'), ('DESEMPLEADO'), ('ESTUDIANTE'), ('PENSIONADO');

INSERT INTO dbo.Ocupacion (Codigo, Nombre) VALUES
 ('O01','DOCENTE'), ('O02','DESARROLLADOR'), ('O03','COMERCIANTE'),
 ('O04','AUXILIAR ADMINISTRATIVO'), ('O05','CONDUCTOR'), ('O06','TÉCNICO DE SOPORTE'),
 ('O07','CONTADOR'), ('O08','OPERARIO'), ('O99','SIN CLASIFICAR');
GO

/* ---------------------------------------------------------------------
   ENTIDADES PRINCIPALES
   Persona     = lo que no cambia entre encuestas   
   Observacion = lo que se mide en cada encuesta    
   --------------------------------------------------------------------- */
CREATE TABLE dbo.Persona (
    PersonaId        INT IDENTITY PRIMARY KEY,
    TipoDocumentoId  INT          NOT NULL REFERENCES dbo.TipoDocumento(TipoDocumentoId),
    NumeroDocumento  NVARCHAR(10) NOT NULL,
    PrimerNombre     NVARCHAR(60) NOT NULL,
    SegundoNombre    NVARCHAR(60) NULL,
    PrimerApellido   NVARCHAR(60) NOT NULL,
    SegundoApellido  NVARCHAR(60) NULL,
    FechaNacimiento  DATE         NULL,     -- NULL si venía imposible (31/02/1990)
    Sexo             NVARCHAR(2)  NULL CHECK (Sexo IN ('F','M','ND')),
    Email            NVARCHAR(100) NULL,    -- NULL si no tenía '@'
    Telefono         NVARCHAR(15) NULL,     -- NULL si era '123'
    CONSTRAINT UQ_Persona UNIQUE (TipoDocumentoId, NumeroDocumento)
);

CREATE TABLE dbo.Observacion (
    ObservacionId      INT IDENTITY PRIMARY KEY,
    PersonaId          INT  NOT NULL REFERENCES dbo.Persona(PersonaId),
    FechaEncuesta      DATE NOT NULL,
    MunicipioId        INT  NOT NULL REFERENCES dbo.Municipio(MunicipioId),
    NivelEducativoId   INT  NOT NULL REFERENCES dbo.NivelEducativo(NivelEducativoId),
    SituacionLaboralId INT  NOT NULL REFERENCES dbo.SituacionLaboral(SituacionLaboralId),
    OcupacionId        INT  NULL     REFERENCES dbo.Ocupacion(OcupacionId),
    Empleador          NVARCHAR(60) NULL,
    TipoContrato       NVARCHAR(15) NULL CHECK (TipoContrato IN ('FIJO','INDEFINIDO','SERVICIOS','NO_APLICA')),
    FechaInicioEmpleo  DATE NULL,
    EdadReportada      TINYINT NULL,
    EstadoCivil        NVARCHAR(15) NULL,
    Zona               NVARCHAR(10) NULL CHECK (Zona IN ('URBANA','RURAL')),
    Direccion          NVARCHAR(100) NULL,
    TipoVivienda       NVARCHAR(15) NULL,
    Estrato            TINYINT NULL CHECK (Estrato BETWEEN 1 AND 6),
    IngresoMensual     DECIMAL(18,2) NULL CHECK (IngresoMensual >= 0),  -- NULL = desconocido, nunca 0 inventado
    GastoMensual       DECIMAL(18,2) NULL CHECK (GastoMensual   >= 0),
    PersonasACargo     INT NULL CHECK (PersonasACargo >= 0),
    TamanoHogar        INT NULL CHECK (TamanoHogar >= 1),
    RegimenSalud       NVARCHAR(15) NULL,
    Discapacidad       NVARCHAR(2)  NULL CHECK (Discapacidad IN ('SI','NO','ND')),
    CanalOrigen        NVARCHAR(15) NULL,
    FechaActualizacion DATETIME2 NULL,
    SourceRowId        INT NOT NULL,   -- trazabilidad hacia el Excel
    CONSTRAINT UQ_Observacion UNIQUE (PersonaId, FechaEncuesta)
);
GO
