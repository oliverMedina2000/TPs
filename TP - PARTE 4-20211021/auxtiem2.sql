CREATE OR REPLACE PROCEDURE "P_GENERAR_TRIGGERS"
    AUTHID CURRENT_USER AS
  
        TYPE T_CUR IS REF CURSOR;
  
        TYPE R_TAB IS RECORD(
            NOMBRE_TABLA VARCHAR2(200),
            NOMBRE_PK VARCHAR2(200)
        );
 
       TYPE T_TAB IS TABLE OF
           R_TAB INDEX BY BINARY_INTEGER;
       l_sql VARCHAR2(4000);
       l_dummy NUMBER;
       l_trigger_name VARCHAR2(30);
       V_TAB T_TAB;
       V_CUR T_CUR;
       ind NUMBER;
       v_tablas VARCHAR2(2000);
       ind_ante NUMBER;
       CURSOR C_TABLAS IS
           SELECT cols.table_name, LISTAGG( cols.column_name, ',')
                                           WITHIN GROUP(
                                           ORDER BY cols.column_name) AS COLUMN_NAME
               FROM all_constraints cons, all_cons_columns cols
               WHERE cols.table_name in (SELECT T.TABLE_NAME
                               FROM   ALL_TABLES T
                               WHERE  T.OWNER = 'BASEDATOS2'
                               AND T.TABLE_NAME LIKE 'D_%')
               AND cons.constraint_type = 'P'
               AND cons.constraint_name = cols.constraint_name
               AND cons.owner = cols.owner
               GROUP BY COLS.TABLE_NAME
               order by table_name;
 
   BEGIN
       FOR REG IN C_TABLAS LOOP
                   l_trigger_name := 'T_' || REG.TABLE_NAME;
                   l_sql :=
                       'CREATE OR replace TRIGGER ' || l_trigger_name ||
                       '  BEFORE INSERT OR UPDATE OR DELETE ON ' || TO_CHAR(REG.TABLE_NAME) ||
                       '  FOR EACH ROW
                       DECLARE
                       OPERACION VARCHAR2(100);
                       BEGIN
                            IF INSERTING THEN
                               OPERACION := ' || q'['INSERTAR']' || ';
                           ELSIF UPDATING THEN
                               OPERACION := ' || q'['ACTUALIZAR']' || ';
                           ELSIF DELETING THEN
                               OPERACION := ' || q'['BORRADO']' || ';
                           END IF;
                           INSERT INTO LOG_TABLAS(FECHA_HORA, OPERACION, NOMBRE_TABLA, CLAVE, USUARIO)
                               VALUES(sysdate, OPERACION, ''' || TO_CHAR(REG.TABLE_NAME) ||''', ''' || TO_CHAR(REG.COLUMN_NAME) ||''', user );
                       END;';
                      -- DBMS_OUTPUT.PUT_LINE(l_sql);
                       EXECUTE IMMEDIATE l_sql;
       END LOOP;
   END;
  /