

USE EncuestaETL;
GO

SELECT (SELECT COUNT(*) FROM dbo.cur_Aceptados) + (SELECT COUNT(*) FROM dbo.cur_Rechazados) AS Procesados,
       (SELECT COUNT(*) FROM dbo.cur_Aceptados)  AS Aceptados,
       (SELECT COUNT(*) FROM dbo.cur_Rechazados) AS Rechazados;

SELECT * FROM dbo.cur_Aceptados ORDER BY SourceRowId;
SELECT * FROM dbo.cur_Rechazados ORDER BY SourceRowId;

SELECT Motivo, COUNT(*) AS Cantidad
FROM dbo.cur_Rechazados GROUP BY Motivo ORDER BY Cantidad DESC;

SELECT COUNT(*) AS AceptadosConBalanceNegativo
FROM dbo.cur_Aceptados WHERE BalanceMensual < 0;

-- Antes vs después de un registro corregido (ej. fila 1: 'andrés' / 'GARCÍA')
SELECT s.SourceRowId, s.DocumentType, s.FirstName, s.LastName, s.MonthlyIncome,
       a.TipoDocumento, a.PrimerNombre, a.PrimerApellido, a.IngresoMensual, a.BalanceMensual
FROM dbo.stg_Personas s
JOIN dbo.cur_Aceptados a ON a.SourceRowId = CAST(s.SourceRowId AS INT)
WHERE a.SourceRowId IN (1, 4);


