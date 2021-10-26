DECLARE 
  TYPE T_NEST IS TABLE OF VARCHAR2(25);
  V_TAB   T_NEST;
BEGIN 
   V_TAB := T_NEST();
   V_TAB.EXTEND(3);
   V_TAB(1) := 'Valor para el indice 1';
   V_TAB(2) := 'Valor para el indice 2';
   V_TAB(3) := 'Valor para el indice 3';
   FOR IND IN 1..V_TAB.LAST LOOP
       DBMS_OUTPUT.PUT_LINE(V_TAB(IND));
   END LOOP;
END;
/