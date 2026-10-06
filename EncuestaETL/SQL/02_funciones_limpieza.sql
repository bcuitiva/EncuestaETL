

USE EncuestaETL;
GO

/* ---------------------------------------------------------------------
   FUNCIONES AUXILIARES
   --------------------------------------------------------------------- */

-- 3.1 Limpia texto: quita tabs y espacios duros, recorta extremos,
--     colapsa espacios internos repetidos y pasa a MAYÚSCULAS.
--     Cadena vacía => NULL (para poder detectar faltantes).
CREATE OR ALTER FUNCTION dbo.fn_LimpiarTexto (@t NVARCHAR(255))
RETURNS NVARCHAR(255)
AS
BEGIN
    DECLARE @s NVARCHAR(255) = @t;
    SET @s = REPLACE(REPLACE(@s, CHAR(9), ' '), NCHAR(160), ' ');
    SET @s = LTRIM(RTRIM(@s));
    WHILE CHARINDEX('  ', @s) > 0
        SET @s = REPLACE(@s, '  ', ' ');
    RETURN NULLIF(UPPER(@s), '');
END;
GO

-- 3.2 Convierte un importe en texto a DECIMAL. Formatos del archivo:
--       '4200000'           -> 4200000.00
--       '$ 14.700.000,00'   -> 14700000.00  (punto = miles, coma = decimal)
--       '1500000,50'        -> 1500000.50
--       '-500000'           -> -500000.00   (se convierte; el cursor lo marca negativo)
--       'dos millones'      -> NULL         (no numérico: NO se inventa el valor)
--     Nunca devuelve 0 para algo desconocido.
CREATE OR ALTER FUNCTION dbo.fn_ParseMonto (@txt NVARCHAR(255))
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @s NVARCHAR(255) = UPPER(LTRIM(RTRIM(@txt)));
    IF @s IS NULL OR @s = '' RETURN NULL;

    SET @s = REPLACE(REPLACE(REPLACE(@s, 'COP', ''), '$', ''), ' ', '');

    IF CHARINDEX(',', @s) > 0                               -- formato alterno
        SET @s = REPLACE(REPLACE(@s, '.', ''), ',', '.');
    ELSE IF LEN(@s) - LEN(REPLACE(@s, '.', '')) > 1         -- varios puntos = miles
        SET @s = REPLACE(@s, '.', '');

    RETURN TRY_CONVERT(DECIMAL(18,2), @s);
END;
GO
