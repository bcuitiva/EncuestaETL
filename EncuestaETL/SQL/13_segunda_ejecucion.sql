
USE EncuestaDW;
GO

SELECT 'Persona' AS Tabla, COUNT(*) AS Filas FROM EncuestaETL.dbo.Persona
UNION ALL SELECT 'Observacion',       COUNT(*) FROM EncuestaETL.dbo.Observacion
UNION ALL SELECT 'DimPersona',        COUNT(*) FROM dbo.DimPersona
UNION ALL SELECT 'DimTiempo',         COUNT(*) FROM dbo.DimTiempo
UNION ALL SELECT 'DimUbicacion',      COUNT(*) FROM dbo.DimUbicacion
UNION ALL SELECT 'DimEducacion',      COUNT(*) FROM dbo.DimEducacion
UNION ALL SELECT 'DimSituacionLaboral', COUNT(*) FROM dbo.DimSituacionLaboral
UNION ALL SELECT 'FactObservacion',   COUNT(*) FROM dbo.FactObservacion;

SELECT TipoDocumentoId, NumeroDocumento, COUNT(*) AS Veces
FROM EncuestaETL.dbo.Persona GROUP BY TipoDocumentoId, NumeroDocumento HAVING COUNT(*) > 1;

SELECT PersonaId, FechaEncuesta, COUNT(*) AS Veces
FROM EncuestaETL.dbo.Observacion GROUP BY PersonaId, FechaEncuesta HAVING COUNT(*) > 1;

SELECT PersonaKey, TiempoKey, COUNT(*) AS Veces
FROM dbo.FactObservacion GROUP BY PersonaKey, TiempoKey HAVING COUNT(*) > 1;

SELECT * FROM EncuestaETL.dbo.EtlEjecucion ORDER BY Id;  -- 2ª corrida: 0 insertados