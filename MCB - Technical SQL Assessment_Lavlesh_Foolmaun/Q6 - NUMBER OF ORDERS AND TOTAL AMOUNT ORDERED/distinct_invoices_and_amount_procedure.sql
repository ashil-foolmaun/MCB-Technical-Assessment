--PROCEDURE TO DISPLAY ORDER AND TOTAL AMOUNT 
create or replace procedure ORDER_AND_TOTAL_AMOUNT
  AS
   c1 SYS_REFCURSOR;
  BEGIN 
    open c1 for
         SELECT 
         S.SUPPLIER_NAME AS "Supplier Name",
         C.SUPP_CONTACT_NAME AS "Supplier Contact Name",
         CASE 
         WHEN INSTR(C.SUPP_CONTACT_NUMBER,',') <>0 THEN  REGEXP_SUBSTR(C.SUPP_CONTACT_NUMBER, '[^,]+')
         ELSE  C.SUPP_CONTACT_NUMBER
         END AS "Supplier Contact No. 1",
         CASE 
         WHEN INSTR(C.SUPP_CONTACT_NUMBER,',') <>0 THEN  REGEXP_SUBSTR(C.SUPP_CONTACT_NUMBER, '[^,]+$')
         ELSE  ''
         END AS "Supplier Contact No. 2",
         COUNT(ORDER_ID) AS "Total Orders",
         TO_CHAR(SUM(O.ORDER_TOTAL_AMOUNT),'99,999,990.00') AS "Order Total Amount" 
         FROM XXBCM_ORDER O
         JOIN XXBCM_SUPPLIER S ON S.SUPPLIER_ID = O.SUPPLIER_ID
         JOIN XXBCM_CONTACT C ON C.CONTACT_ID = S.CONTACT_ID
         WHERE O.ORDER_DATE BETWEEN TO_DATE('01 January 2022','dd Month yyyy') AND TO_DATE('31 August 2022','dd Month yyyy')
         GROUP BY C.SUPP_CONTACT_NUMBER,S.SUPPLIER_NAME,C.SUPP_CONTACT_NAME;
   DBMS_SQL.RETURN_RESULT(c1);

  END;
