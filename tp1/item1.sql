-- item1
UPDATE D_PRODUCTOS D
    SET ( FECHA_ULTIMA_COMPRA, PRECIO_ULTIMA_COMPRA) =
    ( 
        SELECT MAX(MVO.FECHA_OPERACION) AS MAX_FECHA,
            DEO.PRECIO_OPERACION AS PRECIO_OPERACION
        FROM D_MOVIMIENTO_OPERACIONES MVO
        JOIN D_SUCURSAL SUC ON SUC.COD_SUCURSAL = MVO.COD_SUCURSAL
        JOIN D_OPERACIONES OPE ON OPE.COD_OPERACION = MVO.COD_OPERACION
        JOIN D_DETALLE_OPERACIONES DEO ON DEO.ID_OPERACION = MVO.ID_OPERACION
        WHERE MVO.TIPO_REGISTRO = 'A'
        AND OPE.DESC_OPERACION LIKE '%COMPRA%'
        AND DEO.ID_PRODUCTO = D.ID_PRODUCTO 
        AND SUC.DESC_SUCURSAL LIKE '%CASA CENTRAL%'
        GROUP BY 
            DEO.PRECIO_OPERACION, 
            DEO.ID_PRODUCTO, 
            FECHA_OPERACION
        ORDER BY  MAX_FECHA DESC
        FETCH FIRST ROW ONLY 
    )
WHERE EXISTS (
    SELECT MAX(MVO.FECHA_OPERACION) AS MAX_FECHA,
            DEO.PRECIO_OPERACION AS PRECIO_OPERACION
        FROM D_MOVIMIENTO_OPERACIONES MVO
        JOIN D_SUCURSAL SUC ON SUC.COD_SUCURSAL = MVO.COD_SUCURSAL
        JOIN D_OPERACIONES OPE ON OPE.COD_OPERACION = MVO.COD_OPERACION
        JOIN D_DETALLE_OPERACIONES DEO ON DEO.ID_OPERACION = MVO.ID_OPERACION
        WHERE MVO.TIPO_REGISTRO = 'A'
        AND OPE.DESC_OPERACION LIKE '%COMPRA%'
        AND DEO.ID_PRODUCTO = D.ID_PRODUCTO
        AND SUC.DESC_SUCURSAL LIKE '%CASA CENTRAL%'
        GROUP BY 
            DEO.PRECIO_OPERACION, 
            DEO.ID_PRODUCTO, 
            FECHA_OPERACION
        ORDER BY  MAX_FECHA DESC
        FETCH FIRST ROW ONLY 
);
