
--Querying tree for orgchart - traditional
WITH cteDirectReports(ManagerID,EmployeeID,ManagerLevel) 
     AS (SELECT OrganizationNode.GetAncestor(1), 
                OrganizationNode, 
                OrganizationLevel - 1 
         FROM   HumanResources.Employee 
         WHERE  OrganizationLevel = 1 
         UNION ALL 
         SELECT e.OrganizationNode.GetAncestor(1), 
                e.OrganizationNode, 
                OrganizationLevel - 1 
         FROM   HumanResources.Employee e 
                INNER JOIN cteDirectReports d 
                  ON e.OrganizationNode.GetAncestor(1) = d.EmployeeID) 

--select * from ctedirectreports

SELECT   E.businessentityid,co.businessentityid as bossbusinessentityid, Manager = replicate('_',(ManagerLevel) * 4) + CO.LastName + ', ' +
                   CO.FirstName, 
         Employee = C.LastName + ', ' + C.FirstName, 
         ManagerLevel, 
         EmployeeLevel = ManagerLevel + 1 
		 --INTO TempEmployeeHierarchy
FROM     cteDirectReports DR 
         INNER JOIN HumanResources.Employee E 
           ON DR.EmployeeID = E.OrganizationNode 
         INNER JOIN Person.Person C 
           ON E.BusinessEntityID = C.BusinessEntityID 
         INNER JOIN HumanResources.Employee EM 
           ON DR.ManagerID = EM.OrganizationNode 
         INNER JOIN Person.Person CO 
           ON EM.BusinessEntityID = CO.BusinessEntityID 
ORDER BY DR.EmployeeID

--Using Graph Tables

;WITH cteDirectReports 
     (employeebusinessentityid, bossbusinessentityid,managerlevel,employeelevel)
AS
(SELECT  businessentityid AS employeebusinessentityid, 0 AS bossbusinessentityid,managerlevel,employeelevel 
         FROM   HumanResources.EmployeeNode 
         WHERE  EmployeeLevel = 0
UNION ALL 
SELECT a.businessentityid as employeebusinessentityid, b.businessentityid AS bossbusinessentityid,a.managerlevel,a.employeelevel
         FROM   HumanResources.EmployeeNode a,HumanResources.ReportsToLink r, HumanResources.EmployeeNode B, ctEdirectreports d
		 WHERE MATCH(a-(r)->b) AND b.businessentityid = d.employeebusinessentityid
)

--select * from cteDirectReports

SELECT   DR.employeebusinessentityid,DR.bossbusinessentityid as bossbusinessentityid, Manager = replicate('_',(DR.ManagerLevel) * 4) + CO.LastName + ', ' +
                   CO.FirstName, 
         Employee = C.LastName + ', ' + C.FirstName, 
         DR.ManagerLevel, 
         EmployeeLevel = DR.ManagerLevel + 1 
FROM     cteDirectReports DR 
         INNER JOIN HumanResources.EmployeeNode E 
           ON DR.employeebusinessentityID = E.BusinessEntityID 
         INNER JOIN Person.Person C 
           ON E.BusinessEntityID = C.BusinessEntityID 
         INNER JOIN HumanResources.EmployeeNode EB 
           ON DR.bossbusinessentityID = EB.BusinessEntityID 
         INNER JOIN Person.Person CO 
           ON EB.BusinessEntityID = CO.BusinessEntityID 
ORDER BY DR.EmployeeBusinessEntityID


