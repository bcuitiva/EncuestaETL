

USE EncuestaETL;
GO

-- Filas ya limpias, tipadas y deduplicadas (salida del Data Flow de limpieza)
CREATE TABLE dbo.stg_Limpio (
    SourceRowId        INT PRIMARY KEY,
    TipoDocumento      NVARCHAR(5),   NumeroDocumento NVARCHAR(10),
    PrimerNombre       NVARCHAR(60),  SegundoNombre   NVARCHAR(60),
    PrimerApellido     NVARCHAR(60),  SegundoApellido NVARCHAR(60),
    FechaNacimiento    DATE,          Sexo NVARCHAR(2),
    Email              NVARCHAR(100), Telefono NVARCHAR(15),
    FechaEncuesta      DATE,          CodMunicipio NVARCHAR(5),
    NivelEducativo     NVARCHAR(30),  SituacionLaboral NVARCHAR(30),
    CodOcupacion       NVARCHAR(5),   Empleador NVARCHAR(60),
    TipoContrato       NVARCHAR(15),  FechaInicioEmpleo DATE,
    EdadReportada      TINYINT,       EstadoCivil NVARCHAR(15),
    Zona               NVARCHAR(10),  Direccion NVARCHAR(100),
    TipoVivienda       NVARCHAR(15),  Estrato TINYINT,
    IngresoMensual     DECIMAL(18,2), GastoMensual DECIMAL(18,2),
    PersonasACargo     INT,           TamanoHogar INT,
    RegimenSalud       NVARCHAR(15),  Discapacidad NVARCHAR(2),
    CanalOrigen        NVARCHAR(15),  FechaActualizacion DATETIME2
);

-- Rechazos, registros en revisión y duplicados descartados
CREATE TABLE dbo.EtlRechazo (
    Id            INT IDENTITY PRIMARY KEY,
    SourceRowId   INT           NOT NULL,
    Estado        NVARCHAR(12)  NOT NULL CHECK (Estado IN ('RECHAZO','REVISION','DUPLICADO')),
    Motivo        NVARCHAR(500) NOT NULL,
    FechaProceso  DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);

-- Cambios aplicados a cada fila (correcciones)
CREATE TABLE dbo.EtlAuditoria (
    Id            INT IDENTITY PRIMARY KEY,
    SourceRowId   INT            NOT NULL,
    Cambios       NVARCHAR(1000) NOT NULL,
    FechaProceso  DATETIME2      NOT NULL DEFAULT SYSDATETIME()
);

-- Una fila por ejecución de paquete (conteos de las variables Row Count)
CREATE TABLE dbo.EtlEjecucion (
    Id             INT IDENTITY PRIMARY KEY,
    Paquete        NVARCHAR(50) NOT NULL,
    FechaEjecucion DATETIME2    NOT NULL DEFAULT SYSDATETIME(),
    Leidos INT, Validos INT, Revision INT, Rechazados INT, Duplicados INT,
    PersonasInsertadas INT, ObservacionesInsertadas INT
);
GO
