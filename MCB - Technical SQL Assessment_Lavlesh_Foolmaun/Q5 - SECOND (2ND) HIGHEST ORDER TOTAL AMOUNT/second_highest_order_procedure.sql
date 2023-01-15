--PROCEDURE TO DISPLAY 2ND HIGHEST ORDER TOTAL AMOUNT
create or replace procedure SECOND_HIGHEST_ORDER
  AS
   c1 SYS_REFCURSOR;
  BEGIN 
    open c1 for
    WITH selection_list AS (
         SELECT DISTINCT
         LTRIM(REPLACE(O.ORDER_REF,'PO',''),'0') AS "Order Reference", 
         TO_CHAR(O.ORDER_DATE,'Month dd, YYYY') AS "Order Date", 
         UPPER(S.SUPPLIER_NAME) AS "Supplier Name",
         TO_CHAR(O.ORDER_TOTAL_AMOUNT,'99,999,990.00') AS "Order Total Amount", 
         O.ORDER_STATUS AS "Order Status",
         (SELECT LISTAGG(INVOICE_REFERENCE,'|') FROM XXBCM_INVOICE INV WHERE INV.ORDER_ID = O.ORDER_ID) as "Invoice Reference",
         ROW_NUMBER() OVER (ORDER BY ORDER_TOTAL_AMOUNT DESC) AS ROWNUMBER
      FROM XXBCM_ORDER O
      INNER JOIN XXBCM_SUPPLIER S ON S.SUPPLIER_ID = O.SUPPLIER_ID
      )
      SELECT "Order Reference", "Order Date", "Supplier Name", "Order Total Amount", "Order Status","Invoice Reference"  from selection_list WHERE ROWNUMBER = 2 ;
    DBMS_SQL.RETURN_RESULT(c1);

  END;
