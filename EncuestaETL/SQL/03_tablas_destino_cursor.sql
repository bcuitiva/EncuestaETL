

USE EncuestaETL;
GO

/* ---------------------------------------------------------------------
   TABLAS DE DESTINO DEL CURSOR
   --------------------------------------------------------------------- */
IF OBJECT_ID('dbo.cur_Aceptados')  IS NOT NULL DROP TABLE dbo.cur_Aceptados;
IF OBJECT_ID('dbo.cur_Rechazados') IS NOT NULL DROP TABLE dbo.cur_Rechazados;

CREATE TABLE dbo.cur_Aceptados (
    SourceRowId      INT            NOT NULL PRIMARY KEY,
    TipoDocumento    NVARCHAR(5)    NOT NULL,
    NumeroDocumento  NVARCHAR(20)   NOT NULL,
    PrimerNombre     NVARCHAR(100)  NOT NULL,
    SegundoNombre    NVARCHAR(100)  NULL,
    PrimerApellido   NVARCHAR(100)  NOT NULL,
    SegundoApellido  NVARCHAR(100)  NULL,
    IngresoMensual   DECIMAL(18,2)  NOT NULL,
    GastoMensual     DECIMAL(18,2)  NOT NULL,
    BalanceMensual   DECIMAL(18,2)  NOT NULL   -- puede ser negativo
);

CREATE TABLE dbo.cur_Rechazados (
    SourceRowId   INT            NOT NULL,
    Motivo        NVARCHAR(500)  NOT NULL,
    FechaProceso  DATETIME2      NOT NULL DEFAULT SYSDATETIME()
);
GO
