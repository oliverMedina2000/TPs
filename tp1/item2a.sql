-- Item2a
INSERT INTO D_FORMA_PAGO (
    COD_FORMA_PAGO, 
    DESC_FORMA_PAGO, 
    REQUIERE_NRO_COMPROBANTE,
    PORCENTAJE_DESCUENTO,
    PORCENTAJE_RECARGO
) VALUES (
    (SELECT MAX(COD_FORMA_PAGO) FROM D_FORMA_PAGO) + 1,
    'CONTADO OUTLET', 
    1, 
    30, 
    0
);