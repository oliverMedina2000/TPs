CREATE OR REPLACE PROCEDURE P_GENE_PROC 

(TYPE_PROC IN VARCHAR2 DEFAULT 'FUNCTION', 

NAME_IN IN VARCHAR2 DEFAULT 'f_proceso_ab', 

NUM_OF_PARAM IN NUMBER DEFAULT 1, 

IN_OUTPUT_FILE IN BOOLEAN DEFAULT FALSE, 

EXT_FILE_OUTPUT IN VARCHAR2 DEFAULT 'sql', 

DATATYPE IN VARCHAR2 DEFAULT 'VARCHAR2') 

IS 

c_file CONSTANT VARCHAR2 (1000) := NAME_IN || '.' || EXT_FILE_OUTPUT; -- Nombre del archivo de salida 

c_param CONSTANT NUMBER := NUM_OF_PARAM; -- Número de parámetros aceptados por el subproceso 

c_output_screen CONSTANT BOOLEAN := NVL(NOT IN_OUTPUT_FILE, TRUE); 

c_max_param CONSTANT NUMBER := 5; -- Se define internamente un máximo de hasta 5 parámetros a mostrar 

TYPE lines_t IS TABLE OF VARCHAR2 (1000) -- Se declara un tipo de array asociativo 

INDEX BY PLS_INTEGER;  

salida lines_t; -- Se declara una variable del tipo array asociativo 

-- Función para definir los parámetros 

FUNCTION F_NUM_OF_PARAM (num_of_param IN NUMBER) 

RETURN VARCHAR2 

IS 

v_param_id NUMBER; 

v_param_of_inout VARCHAR2 (10) := 'IN'; 

v_param_datatype VARCHAR2 (40) := 'VARCHAR2'; 

v_param_value VARCHAR2 (30) := 'param_'; 

CURSOR cur_params

IS 

SELECT gpp.PARAM_ID as id, 

gpp.PARAM_OF_INOUT as inout, 

gpp.PARAM_DATATYPE as datatype, 

gpp.PARAM_VALUE as val 

INTO v_param_id, v_param_of_inout, v_param_datatype, v_param_value 

FROM T_GENE_PROC_PARAM gpp 

WHERE gpp.PARAM_PROC_NAME_IN = NAME_IN; 

v_param VARCHAR2 (100); 

BEGIN 

DECLARE 

v_i NUMBER := 0; 

BEGIN 

FOR rec IN cur_params

LOOP 

v_i := v_i + 1; 

v_param_id := rec.id; 

v_param_of_inout := rec.inout; 

v_param_datatype := rec.datatype; 

v_param_value := rec.val; 

v_param := v_param || v_param_value || ' ' || v_param_of_inout || ' ' || v_param_datatype ||','; 

EXIT WHEN v_i > NUM_OF_PARAM; 

END LOOP; 

IF v_param IS NULL THEN 

FOR idx IN 1 .. c_param 

LOOP 

v_param := v_param || 'p_' || idx || ' IN VARCHAR2,'; 

EXIT WHEN idx >= c_max_param; 

END LOOP; 

END IF; 

EXCEPTION 

WHEN OTHERS 

THEN 

v_param := NULL; 

END; 

RETURN SUBSTR (v_param,1,LENGTH (v_param)-1); 

EXCEPTION WHEN OTHERS THEN 

RETURN NULL; 

END; 

-- Procedimiento para agregar líneas de cadenas a la variable "salida" 

PROCEDURE P_ADD_LINES (str IN VARCHAR2) 

IS 

BEGIN 

salida (salida.COUNT + 1) := str; 

END; 

-- Procedimiento para imprimir el proceso

PROCEDURE P_PROC_OUTPUT 

IS 

BEGIN 

IF c_output_screen THEN 

FOR idx IN salida.FIRST .. salida.LAST 

LOOP 

DBMS_OUTPUT.put_line (salida (idx)); 

END LOOP; 

ELSE 

/* ******************************************************************************

* Se envía la 'salida' a un archivo en la ubicación «/home/usr/scripts/»,

* pero cambie la ruta de acuerdo a la jerarquía de directorios de su preferencia

* y de su Sistema Operativo.

* Nota: Al ejecutar en Live SQL de Oracle el procedimiento no se compila, 

* debido a un error con UTL_FILE. 

* ******************************************************************************/

DECLARE 

v_file_id UTL_FILE.file_type; 

BEGIN 

v_file_id := UTL_FILE.fopen ('/home/usr/scripts/', c_file, 'W'); -- Crear archivo con permisos de escritura

/* ******************************************************************************

* El usuario que corre el script debe poseer permisos sobre la ruta del archivo

* En el siguiente enlace se explica cómo conceder permisos de lectura y escritura a un usuario 

********************************************************************************/ 

FOR idx IN salida.FIRST .. salida.LAST 

LOOP 

UTL_FILE.put_line (v_file_id, salida (idx)); 

END LOOP; 

UTL_FILE.fclose (v_file_id); 

DBMS_OUTPUT.put_line ('UN ARCHIVO CON PROCESO DINÁMICO HA SIDO CREADO...'); 

EXCEPTION 

WHEN OTHERS 

THEN 

DBMS_OUTPUT.put_line ( 

'ERROR: Falla al crear archivo [' 

|| '/home/usr/scripts/' 

|| c_file 

|| '] '); 

UTL_FILE.fclose (v_file_id); 

END; 

DBMS_OUTPUT.put_line ('UN ARCHIVO CON PROCESO DINÁMICO HA SIDO PROCESADO...'); 

END IF; 

END; 

BEGIN 

-- Validar TYPE_PROC IN ('FUNCTION', 'PROCEDURE') 

-- Agregando la primera línea de cadena "CREATE OR REPLACE FUNCTION NAME_IN (NUM_OF_PARAM)" 

-- Si TYPE_PROC es 'FUNCTION', entonces RETURN DATATYPE, sino es 'PROCEDURE'. 

IF TYPE_PROC IN ('FUNCTION','PROCEDURE') THEN 

P_ADD_LINES ('CREATE OR REPLACE ' || TYPE_PROC || ' ' || NAME_IN ||' (' || F_NUM_OF_PARAM(c_param) || ') '); 

IF TYPE_PROC = 'FUNCTION' THEN 

P_ADD_LINES ('RETURN ' || DATATYPE); 

END IF; 

-- Agregando el resto de las líneas que componen el cuerpo del proceso 

P_ADD_LINES ('IS '); 

P_ADD_LINES ('/* *************************************************************************************'); 

P_ADD_LINES (' * Proceso: ' || NAME_IN); 

P_ADD_LINES (' * Descripción: ' || INITCAP(TYPE_PROC)); 

P_ADD_LINES (' * Parámetros: ' || F_NUM_OF_PARAM(c_param)); 

P_ADD_LINES (' * Retorna: ' || INITCAP(DATATYPE)); 

P_ADD_LINES (' * *************************************************************************************/'); 

P_ADD_LINES (' '); 

P_ADD_LINES (' -- Variables agregadas dinámicamente '); 

-- Agregando el resto de las líneas que componen el cuerpo del proceso 

BEGIN 

FOR rec IN (SELECT gpb.PROC_VALUE AS head 

FROM T_GENE_PROC_VALUE gpb 

WHERE gpb.PROC_TYPE_VALUE = 'HEAD' 

AND gpb.PROC_NAME_IN = NAME_IN 

ORDER BY gpb.PROC_VALUE_LINE) 

LOOP 

P_ADD_LINES (rec.head); 

END LOOP; 

END; 

P_ADD_LINES ('BEGIN '); 

P_ADD_LINES (' -- Líneas agregadas dinámicamente '); 

-- Agregando líneas del BODY 

DECLARE 

v_flag BOOLEAN := FALSE; 

BEGIN 

FOR rec IN (SELECT gpb.PROC_VALUE AS body 

FROM T_GENE_PROC_VALUE gpb 

WHERE gpb.PROC_TYPE_VALUE = 'BODY' 

AND gpb.PROC_NAME_IN = NAME_IN 

ORDER BY gpb.PROC_VALUE_LINE) 

LOOP 

P_ADD_LINES (rec.body); 

v_flag := TRUE; 

END LOOP; 

IF NOT v_flag THEN 

P_ADD_LINES (' NULL; '); 

END IF; 

END; 

P_ADD_LINES (' -- '); 

P_ADD_LINES ('END ' || NAME_IN || ';'); 

P_ADD_LINES ('/'); 

P_PROC_OUTPUT (); 

ELSE 

-- Un un mensaje de error se imprime si TYPE_PROC NOT IN ('FUNCTION','PROCEDURE') 

DBMS_OUTPUT.put_line ( 

'ERROR:' 

|| ' Falla al generar un proceso dinámico (' || NAME_IN || ').'); 

DBMS_OUTPUT.put_line ( 

'REQUIERE: (PARAM) TYPE_PROC ["FUNCTION","PROCEDURE"]'); 

END IF; 

EXCEPTION 

WHEN OTHERS 

THEN 

DBMS_OUTPUT.put_line ( 

'ERROR (' 

|| sqlcode 

|| ') Falla al generar lo siguiente:' 

|| ' [PROCESO: ' 

|| TYPE_PROC 

|| '], [NOMBRE: ' 

|| NAME_IN 

|| '], [PARÁMETRO(S): ' 

|| NUM_OF_PARAM 

|| '], [TIPO DE DATO: ' 

|| DATATYPE ||']'); 

END P_GENE_PROC; 

/