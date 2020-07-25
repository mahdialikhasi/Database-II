CREATE OR ALTER PROCEDURE "customer_mart" as 
begin
	exec fact_customer_transactional_update;
	exec fact_customer_acc_update;
end;