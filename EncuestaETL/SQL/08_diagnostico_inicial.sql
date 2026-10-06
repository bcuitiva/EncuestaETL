
USE EncuestaETL;
GO

-- 4.1 Faltantes por columna
SELECT
  SUM(CASE WHEN NULLIF(LTRIM(DocumentNumber),'') IS NULL THEN 1 ELSE 0 END) AS DocNulo,
  SUM(CASE WHEN DocumentNumber = 'SIN-DATO'               THEN 1 ELSE 0 END) AS DocSinDato,
  SUM(CASE WHEN NULLIF(LTRIM(FirstName),'')      IS NULL THEN 1 ELSE 0 END) AS SinPrimerNombre,
  SUM(CASE WHEN NULLIF(LTRIM(MonthlyExpenses),'')IS NULL THEN 1 ELSE 0 END) AS SinGasto,
  SUM(CASE WHEN NULLIF(LTRIM(HealthRegime),'')   IS NULL OR HealthRegime = 'sin dato' THEN 1 ELSE 0 END) AS SinRegimen
FROM dbo.stg_Personas;

-- 4.2 Escritura inconsistente de categorías. Se agrupa con una intercalación
--     sensible a mayúsculas (CS) para que 'cc' y 'CC' salgan por separado.
SELECT 'DocumentType' AS Campo, DocumentType COLLATE Latin1_General_CS_AS AS Valor, COUNT(*) AS N
FROM dbo.stg_Personas GROUP BY DocumentType COLLATE Latin1_General_CS_AS
UNION ALL SELECT 'EducationLevel', EducationLevel COLLATE Latin1_General_CS_AS, COUNT(*)
FROM dbo.stg_Personas GROUP BY EducationLevel COLLATE Latin1_General_CS_AS
UNION ALL SELECT 'MaritalStatus', MaritalStatus COLLATE Latin1_General_CS_AS, COUNT(*)
FROM dbo.stg_Personas GROUP BY MaritalStatus COLLATE Latin1_General_CS_AS
UNION ALL SELECT 'Disability', Disability COLLATE Latin1_General_CS_AS, COUNT(*)
FROM dbo.stg_Personas GROUP BY Disability COLLATE Latin1_General_CS_AS
UNION ALL SELECT 'Sex', Sex COLLATE Latin1_General_CS_AS, COUNT(*)
FROM dbo.stg_Personas GROUP BY Sex COLLATE Latin1_General_CS_AS
UNION ALL SELECT 'Zone', Zone COLLATE Latin1_General_CS_AS, COUNT(*)
FROM dbo.stg_Personas GROUP BY Zone COLLATE Latin1_General_CS_AS
UNION ALL SELECT 'Stratum', SocioeconomicStratum COLLATE Latin1_General_CS_AS, COUNT(*)
FROM dbo.stg_Personas GROUP BY SocioeconomicStratum COLLATE Latin1_General_CS_AS
ORDER BY Campo, N DESC;

-- 4.3 Importes con formato no numérico
SELECT MonthlyIncome, COUNT(*) AS N
FROM dbo.stg_Personas
WHERE TRY_CONVERT(DECIMAL(18,2), MonthlyIncome) IS NULL OR MonthlyIncome LIKE '-%'
GROUP BY MonthlyIncome ORDER BY N DESC;

-- 4.4 Fechas inválidas
SELECT 'BirthDate' AS Campo, BirthDate AS Valor, COUNT(*) AS N FROM dbo.stg_Personas
WHERE TRY_CONVERT(DATE, BirthDate, 23) IS NULL AND TRY_CONVERT(DATE, BirthDate, 103) IS NULL GROUP BY BirthDate
UNION ALL
SELECT 'SurveyDate', SurveyDate, COUNT(*) FROM dbo.stg_Personas
WHERE TRY_CONVERT(DATE, SurveyDate, 23) IS NULL GROUP BY SurveyDate;

-- 4.5 Contacto inválido
SELECT SUM(CASE WHEN Email NOT LIKE '%_@_%._%' THEN 1 ELSE 0 END) AS EmailSinArroba,
       SUM(CASE WHEN LEN(REPLACE(Phone,'-','')) <> 10 THEN 1 ELSE 0 END) AS TelefonoLongitudInvalida
FROM dbo.stg_Personas;

-- 4.6 Municipio vs departamento incoherente (frente al catálogo)
SELECT s.MunicipalityCode, s.DepartmentCode, d.Codigo AS DeptoSegunCatalogo, COUNT(*) AS N
FROM dbo.stg_Personas s
LEFT JOIN dbo.Municipio m    ON m.Codigo = s.MunicipalityCode
LEFT JOIN dbo.Departamento d ON d.DepartamentoId = m.DepartamentoId
WHERE d.Codigo IS NULL OR d.Codigo <> s.DepartmentCode
GROUP BY s.MunicipalityCode, s.DepartmentCode, d.Codigo ORDER BY N DESC;

-- 4.7 Personas a cargo / tamaño de hogar no válidos
SELECT Dependents, HouseholdSize, COUNT(*) AS N FROM dbo.stg_Personas
WHERE TRY_CONVERT(INT, Dependents) IS NULL OR TRY_CONVERT(INT, Dependents) < 0 OR HouseholdSize = '0'
GROUP BY Dependents, HouseholdSize;

-- 4.8 Duplicados por clave de observación (tipo normalizado + número + fecha)
SELECT UPPER(DocumentType) AS Tipo, DocumentNumber, SurveyDate,
       COUNT(*) AS Veces, STRING_AGG(SourceRowId, ', ') AS Filas,
       COUNT(DISTINCT UpdatedAt) AS VersionesDistintas
FROM dbo.stg_Personas
WHERE DocumentNumber LIKE 'SIM%'
GROUP BY UPPER(DocumentType), DocumentNumber, SurveyDate
HAVING COUNT(*) > 1
ORDER BY DocumentNumber;


