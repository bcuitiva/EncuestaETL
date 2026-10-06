
USE EncuestaETL;

SET NOCOUNT ON;

TRUNCATE TABLE dbo.cur_Aceptados;   -- re-ejecutable sin duplicar
TRUNCATE TABLE dbo.cur_Rechazados;

-- Variables que reciben cada fila
DECLARE @Id INT,
        @TipoDoc NVARCHAR(255),  @NumDoc NVARCHAR(255),
        @Nombre1 NVARCHAR(255),  @Nombre2 NVARCHAR(255),
        @Apell1  NVARCHAR(255),  @Apell2  NVARCHAR(255),
        @IngTxt  NVARCHAR(255),  @GasTxt  NVARCHAR(255);

DECLARE @Ing DECIMAL(18,2), @Gas DECIMAL(18,2), @Motivo NVARCHAR(500);
DECLARE @Procesados INT = 0, @Aceptados INT = 0, @Rechazados INT = 0;

-- (1) DECLARACIÓN
DECLARE cur_Limpieza CURSOR LOCAL FAST_FORWARD FOR
    SELECT CAST(SourceRowId AS INT), DocumentType, DocumentNumber,
           FirstName, MiddleName, LastName, SecondLastName,
           MonthlyIncome, MonthlyExpenses
    FROM dbo.stg_Personas
    WHERE TRY_CAST(SourceRowId AS INT) BETWEEN 1 AND 100
    ORDER BY TRY_CAST(SourceRowId AS INT);

-- (2) APERTURA
OPEN cur_Limpieza;

-- (3) LECTURA de la primera fila
FETCH NEXT FROM cur_Limpieza
    INTO @Id, @TipoDoc, @NumDoc, @Nombre1, @Nombre2, @Apell1, @Apell2, @IngTxt, @GasTxt;

-- (4) RECORRIDO: mientras la última lectura haya traído una fila
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @Procesados += 1;
    SET @Motivo = '';

    -- a) Limpieza y estandarización de texto
    SET @TipoDoc = REPLACE(dbo.fn_LimpiarTexto(@TipoDoc), '.', '');  -- 'cc' -> 'CC'
    SET @NumDoc  = REPLACE(dbo.fn_LimpiarTexto(@NumDoc), ' ', '');
    SET @Nombre1 = dbo.fn_LimpiarTexto(@Nombre1);                    -- 'andrés' -> 'ANDRÉS'
    SET @Nombre2 = dbo.fn_LimpiarTexto(@Nombre2);
    SET @Apell1  = dbo.fn_LimpiarTexto(@Apell1);
    SET @Apell2  = dbo.fn_LimpiarTexto(@Apell2);

    -- 'SIN-DATO' es un marcador de ausencia, no un documento
    IF @NumDoc IN ('SIN-DATO', 'SINDATO', 'N/A', 'NA') SET @NumDoc = NULL;

    -- b) Campos obligatorios
    IF @NumDoc  IS NULL SET @Motivo += 'Sin número de documento; ';
    ELSE IF @NumDoc NOT LIKE 'SIM[0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
                        SET @Motivo += 'Documento con formato inválido; ';
    IF @TipoDoc IS NULL SET @Motivo += 'Sin tipo de documento; ';
    IF @Nombre1 IS NULL SET @Motivo += 'Sin primer nombre; ';
    IF @Apell1  IS NULL SET @Motivo += 'Sin primer apellido; ';

    -- c) Ingreso: faltante / no numérico / negativo
    SET @Ing = dbo.fn_ParseMonto(@IngTxt);
    IF NULLIF(LTRIM(RTRIM(@IngTxt)), '') IS NULL
        SET @Motivo += 'Ingreso faltante; ';
    ELSE IF @Ing IS NULL
        SET @Motivo += 'Ingreso no numérico (' + @IngTxt + '); ';
    ELSE IF @Ing < 0
        SET @Motivo += 'Ingreso negativo; ';

    -- d) Gasto: misma lógica
    SET @Gas = dbo.fn_ParseMonto(@GasTxt);
    IF NULLIF(LTRIM(RTRIM(@GasTxt)), '') IS NULL
        SET @Motivo += 'Gasto faltante; ';
    ELSE IF @Gas IS NULL
        SET @Motivo += 'Gasto no numérico (' + @GasTxt + '); ';
    ELSE IF @Gas < 0
        SET @Motivo += 'Gasto negativo; ';

    -- e) Decisión
    IF @Motivo = ''
    BEGIN
        INSERT INTO dbo.cur_Aceptados
            (SourceRowId, TipoDocumento, NumeroDocumento, PrimerNombre, SegundoNombre,
             PrimerApellido, SegundoApellido, IngresoMensual, GastoMensual, BalanceMensual)
        VALUES
            (@Id, @TipoDoc, @NumDoc, @Nombre1, @Nombre2,
             @Apell1, @Apell2, @Ing, @Gas, @Ing - @Gas);   -- balance negativo = válido
        SET @Aceptados += 1;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.cur_Rechazados (SourceRowId, Motivo)
        VALUES (@Id, LEFT(@Motivo, LEN(@Motivo) - 1));     -- quita el último ';'
        SET @Rechazados += 1;
    END

    -- (3) LECTURA de la siguiente fila (sin esto el WHILE no termina)
    FETCH NEXT FROM cur_Limpieza
        INTO @Id, @TipoDoc, @NumDoc, @Nombre1, @Nombre2, @Apell1, @Apell2, @IngTxt, @GasTxt;
END

-- (5) CIERRE
CLOSE cur_Limpieza;
-- (6) LIBERACIÓN
DEALLOCATE cur_Limpieza;

-- Presentar la cantidad de registros procesados, aceptados y rechazados
SELECT @Procesados AS Procesados, @Aceptados AS Aceptados, @Rechazados AS Rechazados;
