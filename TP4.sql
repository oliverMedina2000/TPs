/*
2. SQL Din�mico:
A. El siguiente script crea una tabla para auditar las sentencias DML sobre las tablas:
CREATE TABLE LOG_TABLAS
(FECHA_HORA TIMESTAMP,
OPERACION VARCHAR2(10),
NOMBRE_TABLA VARCHAR2(30),
CLAVE VARCHAR2(2000),
USUARIO VARCHAR2(30))
/

i. Cree la tabla con el script proporcionado

ii. Cree el procedimiento P_GENERAR_TRIGGERS que recorrer� las tablas del
esquema y crear� din�micamente un trigger con la denominaci�n
T_<nombre_tabla> que deber� dispararse para todas las tablas despu�s de
la inserci�n, borrado o modificaci�n de datos. EL trigger deber� grabar la
fecha de operaci�n, la operaci�n que dispara el DML, el nombre de la tabla,
el usuario que gener� la operaci�n, y en el campo CLAVE ir� la columna
que conforma la PK. Si la PK est� conformada por varias columnas, las
mismas ir�n entre comas
*/

EXECUTE P_GENERAR_TRIGGERS;

CREATE OR REPLACE PROCEDURE P_GENERAR_TRIGGERS IS

    TYPE T_CUR IS REF CURSOR;

    TYPE R_TAB IS RECORD(
        NOMBRE_TABLA VARCHAR2(200),
        NOMBRE_PK VARCHAR2(200)
    );

    TYPE T_TAB IS TABLE OF 
        R_TAB INDEX BY BINARY_INTEGER;

    V_TAB T_TAB;
    V_CUR T_CUR;
    ind NUMBER;
    v_tablas VARCHAR2(2000);
    V_USER VARCHAR2(20) := 'BASEDATOS2';
    V_LIKE VARCHAR2 (20):= 'D_%';
    V_CONST VARCHAR2 (20):= 'P';
BEGIN
    v_tablas := 'SELECT cols.table_name, cols.column_name
            FROM all_constraints cons, all_cons_columns cols
            WHERE cols.table_name in (SELECT T.TABLE_NAME
                            FROM   ALL_TABLES T
                            WHERE  T.OWNER = ' || q'['BASEDATOS2']' || '
                            AND T.TABLE_NAME LIKE ' || q'['D_%']' || ')
            AND cons.constraint_type =  ' || q'['P']' || '
            AND cons.constraint_name = cols.constraint_name
            AND cons.owner = cols.owner
            ORDER BY cols.table_name ASC';
    EXECUTE IMMEDIATE v_tablas
    BULK COLLECT INTO V_TAB;

    /*
    OPEN V_CUR FOR v_tablas;
    FETCH V_CUR BULK COLLECT INTO V_TAB;
    CLOSE V_CUR;
    */
    ind := v_tab.FIRST;
    WHILE ind <= v_tab.LAST LOOP
        -- si el registro es igual al anterior, concatenar el nombre de la columna
        -- si el registro es diferente al anterior, crear el trigger mediante GENERAR_SENTENCIAS_DML
        IF ind > 1 THEN
            IF v_tab(ind).NOMBRE_TABLA = v_tab(ind-1).NOMBRE_TABLA THEN
                v_tab(ind).NOMBRE_PK := v_tab(ind-1).NOMBRE_PK || ', ' || v_tab(ind).NOMBRE_PK;
            ELSE
                GENERAR_SENTENCIAS_DML(v_tab(ind).NOMBRE_TABLA, v_tab(ind).NOMBRE_PK);
            END IF;
        END IF;
        ind := v_tab.NEXT(ind);
    END LOOP;    
END;
/

------ Sentencia para triggers
CREATE OR REPLACE PROCEDURE GENERAR_SENTENCIAS_DML
(
    NOMBRE_TABLA IN VARCHAR2,
    CLAVE_PK IN VARCHAR2
) IS
    sentencia_trigger VARCHAR2(2000);
    --nombre_tabla = 'D_DETALLE_OPERACIONES';
BEGIN
    sentencia_trigger := 'BEGIN
    CREATE OR REPLACE TRIGGER T_'|| TO_CHAR(NOMBRE_TABLA) ||'
    BEFORE INSERT OR UPDATE OR DELETE ON '|| TO_CHAR(NOMBRE_TABLA) ||'
    DECLARE
        OPERACION VARCHAR2;
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
    END T_'|| TO_CHAR(NOMBRE_TABLA) ||';
    END;';  
    EXECUTE IMMEDIATE sentencia_trigger ;
END;
/

------

-- ejemplo de sql dinamico
DECLARE
    v_string VARCHAR2(200);
    
BEGIN
    v_string := 'DROP TABLE B_PLAN_PAGO';
    EXECUTE IMMEDIATE '
    DECLARE
        C_TABLAS IS
            SELECT cols.table_name, cols.column_name, cols.owner
            FROM all_constraints cons, all_cons_columns cols
            WHERE cols.table_name in (SELECT T.TABLE_NAME
                            FROM   ALL_TABLES T
                            WHERE  T.OWNER = 'BASEDATOS2'
                            AND T.TABLE_NAME LIKE 'D_%')
            AND cons.constraint_type = 'P'
            AND cons.constraint_name = cols.constraint_name
            AND cons.owner = cols.owner
            order by table_name; 
    BEGIN
        
    '
END;


-- ejemplo

select table_name from all_tables where owner = 'BASEDATOS2';

-- 
CREATE OR REPLACE TRIGGER T_CONTROL_DML
    AFTER INSERT OR UPDATE OR DELETE ON V_TAB(IND).NOMBRE_TABLA
DECLARE
    OPERACION VARCHAR2;
BEGIN
    IF INSERTING THEN
        OPERACION = 'INSERT'
    ELSIF UPDATING THEN
        OPERACION = 'UPDATE'
    ELSIF DELETING THEN
        OPERACION = 'DELETE'
    END IF;
        INSERT INTO LOG_TABLAS
        VALUES(TO_DATE(sysdate,'yyyy-mm-dd hh24:mi:ss'), OPERACION, V_TAB(IND).NOMBRE_TABLA,V_TAB(IND).CLAVE, )
END T_CONTROL_DML;

------------------------
SELECT cols.table_name, cols.column_name
FROM all_constraints cons, all_cons_columns cols
WHERE cols.table_name in (SELECT TABLE_NAME
                          FROM   ALL_TABLES
                          WHERE  OWNER = 'BASEDATOS2'
                          AND TABLE_NAME LIKE 'D_%')
AND cons.constraint_type = 'P'
AND cons.constraint_name = cols.constraint_name
AND cons.owner = cols.owner;

select trigger_name, trigger_type,
    triggering_event, table_name,
    status, trigger_body
from ALL_TRIGGERS
WHERE OWNER='BASEDATOS2';
select trigger_name
from ALL_TRIGGERS
WHERE OWNER='BASEDATOS2';



-----
create or replace procedure p_generar_triggers is 
    tabla VARCHAR2(10) := 'b_areas'; 
    encabezado VARCHAR2(100) := 'create trigger t_'; 
    v_sentencia VARCHAR2( 8000) ; 
    v_event VARCHAR2(1000) := ' after insert or update or delete on '; 
    v_body varchar2(1000);

begin 
    encabezado := encabezado || tabla; 
    v_event := v_event || tabla; 
    v_body := q'[ for each row 
                    declare 
                    begin 
                        if INSERTING then 
                            DBMS_OUTPUT.PUT_LINE('Todo ok'); 
                        end if; 
                    end ]'; 
    v_sentencia := encabezado ||v_event||v_body; 
    DBMS_OUTPUT.PUT_LINE(v_sentencia); 
    DBMS_OUTPUT.PUT_LINE(' ');

    EXECUTE IMMEDIATE v_sentencia; exception when others then DBMS_OUTPUT.PUT_LINE('Ocurrio un error inesperado '|| sqlerrm); 
end;

CREATE OR REPLACE
PROCEDURE "TRIGGER_CALL" (p_table_name   IN VARCHAR2) 
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

  l_trigger_name := p_table_name || '_trg'; 

  l_sql :=
    'CREATE OR replace TRIGGER ' || l_trigger_name ||
    '  BEFORE INSERT ON ' || p_table_name ||
    '  FOR EACH ROW 
     BEGIN 
       SELECT my_sequence.NEXTVAL 
       INTO   :new.sno 
       FROM   dual;
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