USE EncuestaDW;
GO

SELECT
    SUM(CantidadObservaciones) AS NumeroObservaciones,
    SUM(IngresoMensual) AS SumaIngresos
FROM dbo.FactObservacion;
GO