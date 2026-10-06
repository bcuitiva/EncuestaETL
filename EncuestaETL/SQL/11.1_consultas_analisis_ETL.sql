USE EncuestaETL;
GO

-- Q1. Personas distintas por municipio
SELECT
    m.Nombre AS Municipio,
    COUNT(DISTINCT o.PersonaId) AS PersonasDistintas
FROM dbo.Observacion o
INNER JOIN dbo.Municipio m
    ON o.MunicipioId = m.MunicipioId
GROUP BY
    m.Nombre
ORDER BY
    m.Nombre;
GO

-- Q2. Ingreso promedio por nivel educativo (AVG ignora NULL = desconocidos)
SELECT
    ne.Nombre AS NivelEducativo,
    AVG(o.IngresoMensual) AS IngresoPromedio
FROM dbo.Observacion o
INNER JOIN dbo.NivelEducativo ne
    ON o.NivelEducativoId = ne.NivelEducativoId
GROUP BY
    ne.Nombre
ORDER BY
    ne.Nombre;
GO

-- Q3. Balance promedio por situación laboral
SELECT
    sl.Nombre AS SituacionLaboral,
    AVG(o.IngresoMensual - o.GastoMensual) AS BalancePromedio
FROM dbo.Observacion o
INNER JOIN dbo.SituacionLaboral sl
    ON o.SituacionLaboralId = sl.SituacionLaboralId
GROUP BY
    sl.Nombre
ORDER BY
    sl.Nombre;
GO

-- Q4. Cantidad de observaciones por año y mes
SELECT
    YEAR(o.FechaEncuesta) AS Anio,
    MONTH(o.FechaEncuesta) AS Mes,
    COUNT(*) AS CantidadObservaciones
FROM dbo.Observacion o
GROUP BY
    YEAR(o.FechaEncuesta),
    MONTH(o.FechaEncuesta)
ORDER BY
    YEAR(o.FechaEncuesta),
    MONTH(o.FechaEncuesta);
GO