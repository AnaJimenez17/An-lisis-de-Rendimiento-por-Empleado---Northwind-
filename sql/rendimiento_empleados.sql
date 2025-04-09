ALTER VIEW  Análisis_de_Rendimiento_x_Empleado 
AS*/
select top 10 O.OrderDate, E.FirstName+ ' '+ E.LastName as Empleado, 
	C.CategoryName as Categoria,
	count(O.OrderID) AS Orden_Total,
	count(P.UnitsInStock) as  Stock_Disponible,
	sum(OD.Quantity) AS  Venta_Total,
    --Para calcular el porcentaje de ventas por empleados
	Concat(CAST(ROUND(SUM(OD.Quantity) * 100.0 / SUM(SUM(OD.Quantity)) OVER (PARTITION BY E.EmployeeID), 2) AS DECIMAL(5, 2)), '%') AS Porcentaje_Venta,
	
    --Para calcular el ingreso promedio y promedio total
	Concat('$',cast(ROUND(AVG(ISNULL(OD.UnitPrice, 0) * ISNULL(OD.Quantity, 0)), 2)  AS  DECIMAL(18,2))) AS  Ingreso_Promedio,
	CONCAT('$',cast(ROUND(SUM(ISNULL(OD.UnitPrice, 0) * ISNULL(OD.Quantity, 0))   * (1 - ISNULL (OD.Discount,0)), 2) 	AS DECIMAL(18, 2))) AS  Ingreso_Total,
    CONCAT(CAST(ROUND( SUM(OD.UnitPrice * OD.Quantity * (1 - OD.Discount)) * 100.0 / SUM(SUM(OD.UnitPrice * OD.Quantity * (1 - OD.Discount))) OVER (), 
        2) AS DECIMAL(5, 2)), '%') AS P_Ingreso_x_Empleado

	FROM  [Order Details] OD
		 INNER JOIN Orders O ON O.OrderID = OD.OrderID
		 INNER JOIN Employees E ON E.EmployeeID = O.EmployeeID
		 INNER JOIN Products P ON P.ProductID = OD.ProductID
		 INNER JOIN Categories C ON C.CategoryID = P.CategoryID
		 GROUP BY O.OrderDate, E.FirstName, E.LastName, OD.Discount,
		C.CategoryName, E.EmployeeID  HAVING sum(OD.Quantity)>= 50
		ORDER BY Venta_Total DESC;

 
