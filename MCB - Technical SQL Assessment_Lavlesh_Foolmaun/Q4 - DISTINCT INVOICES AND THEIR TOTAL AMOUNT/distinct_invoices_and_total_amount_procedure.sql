create or replace FUNCTION FUNC_INV_STATUS(r_ORDER_ID IN VARCHAR2)
	RETURN VARCHAR2 IS
	       r_INVOICE_COUNT NUMBER := 0;
	       r_INVOICE_COUNTER NUMBER := 1;
           r_INVOICE_STATUS VARCHAR2(20);
	       r_CMP_PAYMENT_COUNT NUMBER := 0;
	       r_PENDING_PAYMENT_FLAG NUMBER :=0;
	       r_NULL_PAYMENT_FLAG NUMBER := 0; 
	       r_OUTPUT VARCHAR(20);

	BEGIN
		SELECT COUNT(*) INTO r_INVOICE_COUNT FROM XXBCM_INVOICE WHERE ORDER_ID=r_ORDER_ID;

		FOR i IN 1..r_INVOICE_COUNT LOOP
 
            WITH order_INVOICE_STATUS_list AS (
                SELECT INVOICE_STATUS, ROW_NUMBER() OVER (ORDER BY ORDER_ID) AS RNUM
                FROM XXBCM_INVOICE
                WHERE ORDER_ID=r_ORDER_ID
            ) 
            SELECT INVOICE_STATUS INTO r_INVOICE_STATUS
            FROM order_INVOICE_STATUS_list
            WHERE RNUM = i; 

            IF r_INVOICE_STATUS = 'Paid' THEN r_CMP_PAYMENT_COUNT:=r_CMP_PAYMENT_COUNT+1;
            ELSIF r_INVOICE_STATUS = 'Pending' THEN r_PENDING_PAYMENT_FLAG := 1;
            ELSIF r_INVOICE_STATUS IS NULL THEN r_NULL_PAYMENT_FLAG := 1;
            END IF;

            r_INVOICE_COUNTER := r_INVOICE_COUNTER + 1;

            EXIT WHEN r_INVOICE_COUNTER = r_INVOICE_COUNT;
        END LOOP;

		IF r_CMP_PAYMENT_COUNT = r_INVOICE_COUNT THEN r_OUTPUT := 'OK';
	    END IF;
        
	    IF r_PENDING_PAYMENT_FLAG = 1 THEN r_OUTPUT := 'To follow up';
	    END IF;
        
	    IF r_NULL_PAYMENT_FLAG = 1 THEN r_OUTPUT := ' To verify';
	    END IF;
        
	RETURN r_OUTPUT;
	END;
/

create or replace procedure SUMMARY_OF_ORDERS
	AS  
	 c1 SYS_REFCURSOR;  
	BEGIN 
	  open c1 for
	SELECT "Order Reference", "Order Period", "Supplier Name", "Order Total Amount", "Order Status", "Invoice Reference", "Invoice Total Amount", "Action" FROM (
	SELECT DISTINCT LTRIM(REPLACE(N.ORDER_REF,'PO',''),'0') AS "Order Reference", 
	TO_CHAR(N.ORDER_DATE,'MON-YYYY') AS "Order Period", 
	INITCAP(O.SUPPLIER_NAME) AS "Supplier Name",
	TO_CHAR(N.ORDER_TOTAL_AMOUNT,'99,999,990.00') AS "Order Total Amount", 
	N.ORDER_STATUS AS "Order Status",
	M.INVOICE_REFERENCE AS "Invoice Reference",
	TO_CHAR(INVOICE_AMOUNT,'99,999,990.00') AS "Invoice Total Amount",
	FUNC_INV_STATUS(N.ORDER_ID) AS "Action",
	ORDER_DATE
	FROM XXBCM_INVOICE M 
	INNER JOIN XXBCM_ORDER N ON N.ORDER_ID = M.ORDER_ID
	INNER JOIN XXBCM_SUPPLIER O ON O.SUPPLIER_ID = N.SUPPLIER_ID
	ORDER BY N.ORDER_DATE DESC
	);
	 DBMS_SQL.RETURN_RESULT(c1);

	END;
	
/