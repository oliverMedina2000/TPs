CREATE OR REPLACE PROCEDURE GENERAR_SENTENCIAS_DML
(
    NOMBRE_TABLA IN VARCHAR2,
    CLAVE_PK IN VARCHAR2
) IS
    sentencia_trigger VARCHAR2(2000);
    --nombre_tabla = 'D_DETALLE_OPERACIONES';
BEGIN
    sentencia_trigger := '
    CREATE OR REPLACE TRIGGER T_'|| TO_CHAR(NOMBRE_TABLA) ||'
    BEFORE INSERT OR UPDATE OR DELETE ON '|| TO_CHAR(NOMBRE_TABLA) ||'
    DECLARE
        OPERACION VARCHAR28(50);
    BEGIN
        IF INSERTING THEN
            OPERACION = ' || q'['INSERTAR']' || ';
        ELSIF UPDATING THEN
            OPERACION = ' || q'['ACTUALIZAR']' || ';
        ELSIF DELETING THEN
            OPERACION = ' || q'['BORRADO']' || ';
        END IF;
        INSERT INTO LOG_TABLAS(FECHA_HORA, OPERACION, NOMBRE_TABLA, CLAVE, USUARIO)
            VALUES(CURRENT_TIMESTAMP, OPERACION, ' || NOMBRE_TABLA ||', ' || CLAVE_PK ||', (select user from dual)  );
    END;
    ';  
    EXECUTE IMMEDIATE sentencia_trigger ;
END;
/
CREATE SEQUENCE my_sequence;
/

CREATE OR REPLACE
PROCEDURE "TRIGGER_CALL" (p_table_name   IN VARCHAR2, CLAVE_PK IN VARCHAR2) 
AUTHID CURRENT_USER                          
AS 
  l_sql VARCHAR2(4000);
  l_dummy NUMBER;
  l_trigger_name VARCHAR2(30);
BEGIN
  -- Validate if a p_table_name is a valid object name
  -- If you have access you can also use DBMS_ASSERT.SQL_OBJECT_NAME procedure
  SELECT '1'
    INTO l_dummy
    FROM all_tables
   WHERE table_name = UPPER(p_table_name);

  l_trigger_name := 'T_' || p_table_name; 

  l_sql :=
    'CREATE OR replace TRIGGER ' || to_char(l_trigger_name) ||
    '  BEFORE INSERT ON ' || p_table_name ||
    '  FOR EACH ROW 
     BEGIN 
       IF INSERTING THEN
            OPERACION = ' || q'['INSERTAR']' || ';
        ELSIF UPDATING THEN
            OPERACION = ' || q'['ACTUALIZAR']' || ';
        ELSIF DELETING THEN
            OPERACION = ' || q'['BORRADO']' || ';
        END IF;
        INSERT INTO LOG_TABLAS(FECHA_HORA, OPERACION, NOMBRE_TABLA, CLAVE, USUARIO)
            VALUES(CURRENT_TIMESTAMP, OPERACION, ' || p_table_name ||', ' || CLAVE_PK ||', (select user from dual)  );
     END;';

  EXECUTE IMMEDIATE l_sql;
END; 
/

CREATE TABLE my_test(sno NUMBER);
/

BEGIN
  trigger_call('my_test');
END;
/