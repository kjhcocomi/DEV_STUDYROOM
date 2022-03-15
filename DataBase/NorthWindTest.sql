USE Northwind;

-- DB ���� ���캸��
EXEC sp_helpdb 'NorthWind';

-- �ӽ� ���̺� (�ε��� �׽�Ʈ��)
CREATE TABLE Test
(
	EmployeeID	INT NOT NULL,
	LastName	VARCHAR(20) NULL,
	FirstName	NVARCHAR(20) NULL,
	HireDate	DATETIME NULL
)

GO

INSERT INTO Test
SELECT EmployeeID, LastName, FirstName, HireDate
FROM Employees;

SELECT *
FROM Test;

-- FILLFACTOR (���� ������ ���� 1%�� ���)
-- PAD_INDEX  (FILLFACTOR �߰� ������ ����)
-- INDEX �� �׽�Ʈ �ϱ� ���� ������ ��ȿ�������� ���
CREATE INDEX Test_Index ON Test(LastName)
WITH (FILLFACTOR = 1, PAD_INDEX = ON)
GO

-- �ε��� ��ȣ ã��
SELECT index_id, name
FROM sys.indexes
WHERE object_id = object_id('Test');

-- 2�� �ε��� ���� ���캸��
DBCC IND('NorthWind', 'Test', 2);

-- Index Level : Root(2) -> ... Leaf(0)

-- HEAP RID ([������ �ּ�(4)][����ID(2)][���Թ�ȣ(2)])
DBCC PAGE('NorthWind', 1/*���Ϲ�ȣ*/, 840/*��������ȣ*/, 3/*��¿ɼ�*/);
DBCC PAGE('NorthWind', 1/*���Ϲ�ȣ*/, 848/*��������ȣ*/, 3/*��¿ɼ�*/);
DBCC PAGE('NorthWind', 1/*���Ϲ�ȣ*/, 880/*��������ȣ*/, 3/*��¿ɼ�*/);

-- Random Access (�� �� �б� ���� �� �������� ����)
-- Bookmark Lookup (RID�� ���� ���� ã�´�.)


-- ���� �ε���

-- �ֹ� �� ������ ���캸��
SELECT *
FROM [Order Details]
ORDER BY OrderID;

-- �ӽ� �׽�Ʈ ���̺��� ����� ������ �����Ѵ�
SELECT *
INTO TestOrderDetails
FROM [Order Details];

SELECT *
FROM TestOrderDetails;

-- ���� �ε��� �߰�
CREATE INDEX Index_TestOrderDetails
ON TestOrderDetails(OrderID, ProductID);

-- �ε��� ���� ���캸��
EXEC sp_helpindex 'TestOrderDetails';

-- INDEX SEEK -> GOOD
-- INDEX SCAN (INDEX FULL SCAN) -> BAD

-- �ε��� ���� �׽�Ʈ 1 -> GOOD
SELECT *
FROM TestOrderDetails
WHERE OrderID = 10248 AND ProductID = 11;

-- �ε��� ���� �׽�Ʈ 2 -> GOOD
SELECT *
FROM TestOrderDetails
WHERE ProductID = 11 AND OrderID = 10248;

-- �ε��� ���� �׽�Ʈ 3 -> GOOD ???
SELECT *
FROM TestOrderDetails
WHERE OrderID = 10248;

-- �ε��� ���� �׽�Ʈ 4 -> BAD
SELECT *
FROM TestOrderDetails
WHERE ProductID = 11;

DBCC IND('NorthWind', 'TestOrderDetails', 2);

--         920
-- 856 888 889 890 891 892

DBCC PAGE('NorthWind', 1, 856, 3);

-- ���� �ε���(A, B) ������̶�� �ε���(A) ��� ����
-- ������ B�ε� �˻��� �ʿ��ϴٸ� -> �ε���(B)�� ������ �ɾ���� ��

-- �ε����� �����Ͱ� �߰�/����/���� �Ǿ �����Ǿ�� ��
-- ������ 50���� ������ �־��.
-- 10248/11, 10387/24

DECLARE @i INT = 0;
WHILE @i < 50
BEGIN
	INSERT INTO TestOrderDetails
	VALUES (10248, 100 + @i, 10, 1, 0);
	SET @i = @i + 1;
END

-- 921 �������� ���� ����

--				920
-- 856 [921] 888 889 890 891 892

DBCC PAGE('NorthWind', 1, 856, 3);
DBCC PAGE('NorthWind', 1, 921, 3);

-- �����Ͱ� �������� ���ο� �������� ���� �и��Ͽ� �����Ѵ�.
-- ��� : ������ ���� ������ ���ٸ� -> ������ ����(SPLIT) �߻�

-- ���� �׽�Ʈ
SELECT LastName
INTO TestEmployees
FROM Employees

SELECT *
FROM TestEmployees;

-- �ε��� �߰�
CREATE INDEX INDEX_TestEmployees
ON TestEmployees(LastName);

-- INDEX SCAN -> BAD
SELECT *
FROM TestEmployees
WHERE SUBSTRING(LastName, 1, 2) = 'Bu';

-- INDEX SEEK
SELECT *
FROM TestEmployees
WHERE LastName LIKE 'Bu%';

-- ������ ���
-- ���� �ε���(A, B)�� ����� �� ���� ����(A->B ���� �˻�)
-- �ε��� ��� ��, ������ �߰��� ���� ������ ���� ������ ������ SPLIT
-- Ű ������ �� ����!


-- �ε��� ����
-- Clustered(���� ����) vs Non-Clustered(����)

-- Clustered
	-- Leaf Page = Data Page
	-- �����ʹ� Clustered Index Ű ������ ����

-- Non-Clustered ? (��� Clustered Index ������ ���� �ٸ��� ����)
-- 1) Clustered Index�� ���� ���
	-- �����ʹ� Heap Table�̶�� ���� ����
	-- Heap RID -> Heap Table�� ���� ������ ����

-- 2) Clustered Index�� �ִ� ���
	-- Heap Table�� ����. Leaf Table�� ���� �����Ͱ� �ִ�.
	-- Clustered Index�� ���� Ű ���� ��� �ִ´�.


-- �ӽ� �׽�Ʈ ���̺��� ����� ������ ����
SELECT *
INTO TestOrderDetails
FROM [Order Details];

SELECT *
FROM TestOrderDetails;

-- �ε��� �߰�
CREATE INDEX Index_OrderDetails
ON TestOrderDetails(OrderID, ProductID);

-- �ε��� ����
EXEC sp_helpindex 'TestOrderDetails';

-- �ε��� ��ȣ ã��
SELECT index_id, name
FROM sys.indexes
WHERE object_id = object_id('TestOrderDetails');

-- ��ȸ
-- PageType 1(DATA PAGE) 2(INDEX PAGE)
DBCC IND('NorthWind', 'TestOrderDetails', 2);

--           936
-- 856 888 889 890 891 892
-- HEAP RID ([������ �ּ�(4)][����ID(2)][���Թ�ȣ(2)])
-- HEAP TABLE[ {Page}, {Page}, {Page}, {Page} ]
DBCC PAGE('NorthWind', 1, 856, 3);

-- Clustered �ε��� �߰�
CREATE CLUSTERED INDEX Index_OrderDetails_Clustered
ON TestOrderDetails(OrderID);

-- Non-Clustered
DBCC PAGE('NorthWind', 1, 976, 3);

-- ��ȸ
-- PageType 1(DATA PAGE) 2(INDEX PAGE)
DBCC IND('NorthWind', 'TestOrderDetails', 1);

--				   968
-- 912 928 929 930 931 932 933 934 935 944



-- �ε��� ���� ��� (Access)
-- Index Scan vs Index Seek

CREATE TABLE TestAccess
(
	id INT NOT NULL,
	name NCHAR(50) NOT NULL,
	dummy NCHAR(1000) NULL
);
GO

CREATE CLUSTERED INDEX TestAccess_CI
ON TestAccess(id);
GO

CREATE NONCLUSTERED INDEX TestAccess_NCI
ON TestAccess(name);
GO

DECLARE @i INT;
SET @i = 1;

WHILE (@i <= 500)
BEGIN
	INSERT INTO TestAccess
	VALUES (@i, 'Name' + CONVERT(VARCHAR, @i), 'Hello World' + CONVERT(VARCHAR, @i));
	SET @i = @i + 1;
END

-- �ε��� ����
EXEC sp_helpindex 'TestAccess';

-- �ε��� ����
SELECT index_id, name
FROM sys.indexes
WHERE object_id = object_id('TestAccess');

-- ��ȸ
DBCC IND('NorthWind', 'TestAccess', 1);
DBCC IND('NorthWind', 'TestAccess', 2);

-- CLUSTERED(1) : id
-- 857
-- 856 858 ... 1127 (167��)

-- NONCLUSTERED(2) : name
-- 865
-- 864 .... 866 (13��)

-- ���� �б� -> ���� �����͸� ã�� ���� ���� ������ ��
SET STATISTICS TIME ON;
SET STATISTICS IO ON;
SET STATISTICS PROFILE ON;

-- INDEX SCAN
SELECT *
FROM TestAccess;

SELECT *
FROM TestAccess
WHERE id = 104;

SELECT *
FROM TestAccess
WHERE name = 'Name55';

-- INDEX SCAN + KEY LOOKUP
SELECT TOP 10 *
FROM TestAccess
ORDER BY name DESC;

-- �ϸ�ũ ���

-- Clustered�� ��� Index Seek�� ���� ���� ����
-- NonClustered�� ���, �����Ͱ� Leaf Page�� ����
-- ���� �ѹ� �� Ÿ�� ������
	-- 1) RID -> Heap Table (Bookmark Lookup)
	-- 2) Key -> Clustered

SELECT *
INTO TestOrders
FROM Orders;

SELECT *
FROM TestOrders;

CREATE NONCLUSTERED INDEX Orders_Index01
ON TestOrders(CustomerID);

-- �ε��� ��ȣ
SELECT index_id, name
FROM sys.indexes
WHERE object_id = object_id('TestOrders');

-- ��ȸ
DBCC IND('NorthWind', 'TestOrders', 2);

-- 1200
-- 1128 1168 1169
-- Heap Table [ {page}, {page}]

-- �⺻ Ž���� �غ���
SELECT *
FROM TestOrders
WHERE CustomerID = 'QUICK';

-- ������ �ε����� �̿��ϰ� �غ���
SELECT *
FROM TestOrders WITH(INDEX(Orders_Index01))
WHERE CustomerID = 'QUICK'

SELECT *
FROM TestOrders WITH(INDEX(Orders_Index01))
WHERE CustomerID = 'QUICK' AND ShipVia = 3;

DROP INDEX TestOrders.Orders_Index01;

-- Covered Index
-- DML(INSERT, UPDATE, DELETE) �۾� ����
CREATE NONCLUSTERED INDEX Orders_Index01
ON TestOrders(CustomerID, Shipvia);

SELECT *
FROM TestOrders WITH(INDEX(Orders_Index01))
WHERE CustomerID = 'QUICK' AND ShipVia = 3;

--
DROP INDEX TestOrders.Orders_Index01;

-- Leaf Page�� Shipvia ������ �� �� �ְ� �ؼ� HEAP TALBE���� ���� �ʾƵ� ��
CREATE NONCLUSTERED INDEX Orders_Index01
ON TestOrders(CustomerID) INCLUDE (Shipvia);

SELECT *
FROM TestOrders WITH(INDEX(Orders_Index01))
WHERE CustomerID = 'QUICK' AND ShipVia = 3;

-- ���
-- NonClustered Index�� �ǿ����� �ִ� ���?
	-- �ϸ�ũ ����� �ɰ��� ���ϸ� �߱��� ��
-- ���
	-- �ɼ� 1) Covered Index(�˻��� ��� �÷��� �����ϰڴ�.)
	-- �ɼ� 2) Index�� Include�� ��Ʈ�� �����.
	-- �ɼ� 3) Clustered ��� (��, 1���� ����� �� �ִ� �ñر�) -> NonClustered�� �ǿ����� �� �� ����




------------------

-- ���� �ε��� �÷� ����
-- Index(A, B, C)

DROP TABLE TestOrders;

SET STATISTICS TIME ON;
SET STATISTICS IO ON;
SET STATISTICS PROFILE ON;

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
SET STATISTICS PROFILE OFF;

-- Leaf Page Ž���� ������ �����Ѵ�.

SELECT *
INTO TestOrders
FROM Orders;

GO
DECLARE @i INT = 1;
DECLARE @emp INT;
SELECT @emp = MAX(employeeID) FROM Orders;

-- ���� �����͸� ��û �ø���

WHILE (@i < 1000)
BEGIN
	INSERT INTO TestOrders(CustomerID, EmployeeID, OrderDate)
	SELECT CustomerID, @emp + @i, OrderDate
	FROM Orders;
	SET @i = @i + 1;
END

SELECT COUNT(*)
FROM TestOrders;

CREATE NONCLUSTERED INDEX idx_emp_ord
ON TestOrders(EmployeeID, OrderDate);

CREATE NONCLUSTERED INDEX idx_ord_imp
ON TestOrders(OrderDate, EmployeeID);

-- �ΰ� ��
SELECT *
FROM TestOrders WITH(INDEX(idx_emp_ord))
WHERE EmployeeID = 1 AND OrderDate = '19970101';

SELECT *
FROM TestOrders WITH(INDEX(idx_ord_imp))
WHERE EmployeeID = 1 AND OrderDate = '19970101';

-- ���� ���캸��
SELECT *
FROM TestOrders
ORDER BY EmployeeID, OrderDate;

SELECT *
FROM TestOrders
ORDER BY OrderDate, EmployeeID;

-- ������ ã�´ٸ�?
SELECT *
FROM TestOrders WITH(INDEX(idx_emp_ord))
WHERE EmployeeID = 1 AND OrderDate BETWEEN '19970101' AND '19970103';

SELECT *
FROM TestOrders WITH(INDEX(idx_ord_imp))
WHERE EmployeeID = 1 AND OrderDate BETWEEN '19970101' AND '19970103';

-- Index(a, b, c)�� �����Ǿ��� ��, ���࿡ between ��� -> ������ �ε��� ��� ���

-- Between ������ ���� �� -> IN-LIST �� ��ü�ϴ� ���� ��� (��ǻ� ������ = )
SELECT *
FROM TestOrders WITH(INDEX(idx_ord_imp))
WHERE EmployeeID = 1 AND OrderDate IN('19970101','19970102','19970103');

-- ������ ��� --
-- ���� �÷� �ε��� (����, ����) ������ ������ �� �� ����
-- BETWEEN, �ε�ȣ ���࿡ ����, ������ �ε��� ����� ���
-- BETWEEN ������ ������ IN-LIST �� ��ü�ϸ� ���� ��쵵 �ִ�. (���࿡ BETWEEN)
-- ������ =, ������ BETWEEN�̸� �ƹ��� ������ ���� ������ IN-LIST X



-- ���� ����
	-- 1) Nested Loop (NL) ����
	-- 2) Merge (����) ����
	-- 3) Hash (�ؽ�) ����

USE BaseballData;

-- Merge
SELECT *
FROM players AS p
	INNER JOIN salaries AS s
	ON p.playerID = s.playerID;

-- NL
SELECT TOP 5 *
FROM players AS p
	INNER JOIN salaries AS s
	ON p.playerID = s.playerID;

-- Hash
SELECT *
FROM salaries AS s
	INNER JOIN teams AS t
	ON s.teamID = t.teamID;


-- NL
SELECT *
FROM players AS p
	INNER JOIN salaries AS s
	ON p.playerID = s.playerID
	OPTION(LOOP JOIN);

SELECT *
FROM players AS p
	INNER JOIN salaries AS s
	ON p.playerID = s.playerID
	OPTION(FORCE ORDER, LOOP JOIN);

-- ������ ���
-- NL Ư¡
-- ���� �׼����� (OUTER) ���̺��� �ο츦 ���� ���� -> (INNER) ���̺� ���� ������
-- (INNER) ���̺� �ε����� ������ ���
-- �κй��� ó���� ���� (ex. TOP 5)


-- Merge(����) ����