
USE EncuestaETL;
GO

SELECT Estado, COUNT(*) AS Filas FROM dbo.EtlRechazo GROUP BY Estado
UNION ALL SELECT 'CARGADAS (Observacion)', COUNT(*) FROM dbo.Observacion;

SELECT Estado, Motivo, COUNT(*) AS Filas
FROM dbo.EtlRechazo GROUP BY Estado, Motivo ORDER BY Estado, Filas DESC;

SELECT * FROM dbo.stg_Personas WHERE SourceRowId IN ('4','18','3','826','976');
SELECT * FROM dbo.Observacion   WHERE SourceRowId IN (4, 18, 826, 976);
SELECT p.* FROM dbo.Persona p JOIN dbo.Observacion o ON o.PersonaId = p.PersonaId WHERE o.SourceRowId IN (4, 18);
SELECT * FROM dbo.EtlRechazo    WHERE SourceRowId IN (3, 826, 976);
SELECT * FROM dbo.EtlAuditoria  WHERE SourceRowId IN (4, 18);


