

USE EncuestaDW;
GO

-- Q1. Personas distintas por municipio
SELECT
    u.Municipio,
    COUNT(DISTINCT f.PersonaKey) AS PersonasDistintas
FROM dbo.FactObservacion f
INNER JOIN dbo.DimUbicacion u
    ON f.UbicacionKey = u.UbicacionKey
GROUP BY
    u.Municipio
ORDER BY
    u.Municipio;
GO

-- Q2. Ingreso promedio por nivel educativo (AVG ignora NULL = desconocidos)
SELECT
    e.NivelEducativo,
    AVG(f.IngresoMensual) AS IngresoPromedio
FROM dbo.FactObservacion f
INNER JOIN dbo.DimEducacion e
    ON f.EducacionKey = e.EducacionKey
GROUP BY
    e.NivelEducativo
ORDER BY
    e.NivelEducativo;
GO

-- Q3. Balance promedio por situación laboral
SELECT
    s.SituacionLaboral,
    AVG(f.BalanceMensual) AS BalancePromedio
FROM dbo.FactObservacion f
INNER JOIN dbo.DimSituacionLaboral s
    ON f.SituacionLaboralKey = s.SituacionLaboralKey
GROUP BY
    s.SituacionLaboral
ORDER BY
    s.SituacionLaboral;
GO

-- Q4. Cantidad de observaciones por año y mes
SELECT
    t.Anio,
    t.Mes,
    SUM(f.CantidadObservaciones) AS CantidadObservaciones
FROM dbo.FactObservacion f
INNER JOIN dbo.DimTiempo t
    ON f.TiempoKey = t.TiempoKey
GROUP BY
    t.Anio,
    t.Mes
ORDER BY
    t.Anio,
    t.Mes;
GO


