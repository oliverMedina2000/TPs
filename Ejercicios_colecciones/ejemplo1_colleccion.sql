DECLARE
 TYPE t_poblacion IS TABLE OF NUMBER INDEX BY VARCHAR2(64);
  poblacion_pais  t_poblacion;
  cantidad NUMBER;
  v_ind VARCHAR2(64);
BEGIN
 poblacion_pais('China')  := 1321000000;
 poblacion_pais('EEUU')   := 302750000;
 poblacion_pais('Brasil') := 186990000;
 poblacion_pais('Paraguay') := 8000000;
 v_ind := poblacion_pais.FIRST;
 WHILE  v_ind <= poblacion_pais.LAST LOOP
        DBMS_OUTPUT.PUT_LINE('Indice es ' || v_ind);
        DBMS_OUTPUT.PUT_LINE('valor es ' || poblacion_pais(v_ind));
        v_ind := poblacion_pais.NEXT(v_ind);
 END LOOP;
END;
/
