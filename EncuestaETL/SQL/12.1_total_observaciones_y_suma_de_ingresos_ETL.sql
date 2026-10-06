USE EncuestaETL;
GO

SELECT
    COUNT(*) AS NumeroObservaciones,
    SUM(IngresoMensual) AS SumaIngresos
FROM dbo.Observacion;
GO 