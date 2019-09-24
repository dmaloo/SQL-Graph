--Query using older method
--Some component ids are used more than once on multiple boms so pick one that is used once
--use AdventureWorks2017
--go
DECLARE @checkdate datetime, @startproductid INT
select @checkdate = getdate()
SELECT @startproductid = 993
--exec [dbo].[uspGetBillOfMaterials] @startproductid, @checkdate
exec [dbo].[uspGetBillOfMaterials_Graph] @startproductid, @checkdate



