USE Northwind;

-- DB 정보 살펴보기
EXEC sp_helpdb 'NorthWind';

-- 임시 테이블 (인덱스 테스트용)
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

-- FILLFACTOR (리프 페이지 공간 1%만 사용)
-- PAD_INDEX  (FILLFACTOR 중간 페이지 적용)
-- INDEX 를 테스트 하기 위해 공간을 비효율적으로 사용
CREATE INDEX Test_Index ON Test(LastName)
WITH (FILLFACTOR = 1, PAD_INDEX = ON)
GO

-- 인덱스 번호 찾기
SELECT index_id, name
FROM sys.indexes
WHERE object_id = object_id('Test');

-- 2번 인덱스 정보 살펴보기
DBCC IND('NorthWind', 'Test', 2);

-- Index Level : Root(2) -> ... Leaf(0)

-- HEAP RID ([페이지 주소(4)][파일ID(2)][슬롯번호(2)])
DBCC PAGE('NorthWind', 1/*파일번호*/, 840/*페이지번호*/, 3/*출력옵션*/);
DBCC PAGE('NorthWind', 1/*파일번호*/, 848/*페이지번호*/, 3/*출력옵션*/);
DBCC PAGE('NorthWind', 1/*파일번호*/, 880/*페이지번호*/, 3/*출력옵션*/);

-- Random Access (한 건 읽기 위해 한 페이지씩 접근)
-- Bookmark Lookup (RID를 통해 행을 찾는다.)


-- 복합 인덱스

-- 주문 상세 정보를 살펴보다
SELECT *
FROM [Order Details]
ORDER BY OrderID;

-- 임시 테스트 테이블을 만들고 데이터 복사한다
SELECT *
INTO TestOrderDetails
FROM [Order Details];

SELECT *
FROM TestOrderDetails;

-- 복합 인덱스 추가
CREATE INDEX Index_TestOrderDetails
ON TestOrderDetails(OrderID, ProductID);

-- 인덱스 정보 살펴보기
EXEC sp_helpindex 'TestOrderDetails';

-- INDEX SEEK -> GOOD
-- INDEX SCAN (INDEX FULL SCAN) -> BAD

-- 인덱스 적용 테스트 1 -> GOOD
SELECT *
FROM TestOrderDetails
WHERE OrderID = 10248 AND ProductID = 11;

-- 인덱스 적용 테스트 2 -> GOOD
SELECT *
FROM TestOrderDetails
WHERE ProductID = 11 AND OrderID = 10248;

-- 인덱스 적용 테스트 3 -> GOOD ???
SELECT *
FROM TestOrderDetails
WHERE OrderID = 10248;

-- 인덱스 적용 테스트 4 -> BAD
SELECT *
FROM TestOrderDetails
WHERE ProductID = 11;

DBCC IND('NorthWind', 'TestOrderDetails', 2);

--         920
-- 856 888 889 890 891 892

DBCC PAGE('NorthWind', 1, 856, 3);

-- 따라서 인덱스(A, B) 사용중이라면 인덱스(A) 없어도 무방
-- 하지만 B로도 검색이 필요하다면 -> 인덱스(B)는 별도로 걸어줘야 함

-- 인덱스는 데이터가 추가/갱신/삭제 되어도 유지되어야 함
-- 데이터 50개를 강제로 넣어보자.
-- 10248/11, 10387/24

DECLARE @i INT = 0;
WHILE @i < 50
BEGIN
	INSERT INTO TestOrderDetails
	VALUES (10248, 100 + @i, 10, 1, 0);
	SET @i = @i + 1;
END

-- 921 페이지가 새로 생김

--				920
-- 856 [921] 888 889 890 891 892

DBCC PAGE('NorthWind', 1, 856, 3);
DBCC PAGE('NorthWind', 1, 921, 3);

-- 데이터가 많아지면 새로운 페이지를 만들어서 분리하여 관리한다.
-- 결론 : 페이지 여유 공간이 없다면 -> 페이지 분할(SPLIT) 발생

-- 가공 테스트
SELECT LastName
INTO TestEmployees
FROM Employees

SELECT *
FROM TestEmployees;

-- 인덱스 추가
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

-- 오늘의 결론
-- 복합 인덱스(A, B)를 사용할 때 순서 주의(A->B 순서 검색)
-- 인덱스 사용 시, 데이터 추가로 인해 페이지 여유 공간이 없으면 SPLIT
-- 키 가공할 때 주의!


-- 인덱스 종류
-- Clustered(영한 사전) vs Non-Clustered(색인)

-- Clustered
	-- Leaf Page = Data Page
	-- 데이터는 Clustered Index 키 순서로 정렬

-- Non-Clustered ? (사실 Clustered Index 유무에 따라 다르게 동작)
-- 1) Clustered Index가 없는 경우
	-- 데이터는 Heap Table이라는 곳에 저장
	-- Heap RID -> Heap Table에 접근 데이터 추출

-- 2) Clustered Index가 있는 경우
	-- Heap Table이 없음. Leaf Table에 실제 데이터가 있다.
	-- Clustered Index의 실제 키 값을 들고 있는다.


-- 임시 테스트 테이블을 만들고 데이터 복사
SELECT *
INTO TestOrderDetails
FROM [Order Details];

SELECT *
FROM TestOrderDetails;

-- 인덱스 추가
CREATE INDEX Index_OrderDetails
ON TestOrderDetails(OrderID, ProductID);

-- 인덱스 정보
EXEC sp_helpindex 'TestOrderDetails';

-- 인덱스 번호 찾기
SELECT index_id, name
FROM sys.indexes
WHERE object_id = object_id('TestOrderDetails');

-- 조회
-- PageType 1(DATA PAGE) 2(INDEX PAGE)
DBCC IND('NorthWind', 'TestOrderDetails', 2);

--           936
-- 856 888 889 890 891 892
-- HEAP RID ([페이지 주소(4)][파일ID(2)][슬롯번호(2)])
-- HEAP TABLE[ {Page}, {Page}, {Page}, {Page} ]
DBCC PAGE('NorthWind', 1, 856, 3);

-- Clustered 인덱스 추가
CREATE CLUSTERED INDEX Index_OrderDetails_Clustered
ON TestOrderDetails(OrderID);

-- Non-Clustered
DBCC PAGE('NorthWind', 1, 976, 3);

-- 조회
-- PageType 1(DATA PAGE) 2(INDEX PAGE)
DBCC IND('NorthWind', 'TestOrderDetails', 1);

--				   968
-- 912 928 929 930 931 932 933 934 935 944



-- 인덱스 접근 방식 (Access)
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

-- 인덱스 정보
EXEC sp_helpindex 'TestAccess';

-- 인덱스 정보
SELECT index_id, name
FROM sys.indexes
WHERE object_id = object_id('TestAccess');

-- 조회
DBCC IND('NorthWind', 'TestAccess', 1);
DBCC IND('NorthWind', 'TestAccess', 2);

-- CLUSTERED(1) : id
-- 857
-- 856 858 ... 1127 (167개)

-- NONCLUSTERED(2) : name
-- 865
-- 864 .... 866 (13개)

-- 논리적 읽기 -> 실제 데이터를 찾기 위해 읽은 페이지 수
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

-- 북마크 룩업

-- Clustered의 경우 Index Seek가 느릴 수가 없다
-- NonClustered의 경우, 데이터가 Leaf Page에 없다
-- 따라서 한번 더 타고 가야함
	-- 1) RID -> Heap Table (Bookmark Lookup)
	-- 2) Key -> Clustered

SELECT *
INTO TestOrders
FROM Orders;

SELECT *
FROM TestOrders;

CREATE NONCLUSTERED INDEX Orders_Index01
ON TestOrders(CustomerID);

-- 인덱스 번호
SELECT index_id, name
FROM sys.indexes
WHERE object_id = object_id('TestOrders');

-- 조회
DBCC IND('NorthWind', 'TestOrders', 2);

-- 1200
-- 1128 1168 1169
-- Heap Table [ {page}, {page}]

-- 기본 탐색을 해보자
SELECT *
FROM TestOrders
WHERE CustomerID = 'QUICK';

-- 강제로 인덱스를 이용하게 해보자
SELECT *
FROM TestOrders WITH(INDEX(Orders_Index01))
WHERE CustomerID = 'QUICK'

SELECT *
FROM TestOrders WITH(INDEX(Orders_Index01))
WHERE CustomerID = 'QUICK' AND ShipVia = 3;

DROP INDEX TestOrders.Orders_Index01;

-- Covered Index
-- DML(INSERT, UPDATE, DELETE) 작업 부하
CREATE NONCLUSTERED INDEX Orders_Index01
ON TestOrders(CustomerID, Shipvia);

SELECT *
FROM TestOrders WITH(INDEX(Orders_Index01))
WHERE CustomerID = 'QUICK' AND ShipVia = 3;

--
DROP INDEX TestOrders.Orders_Index01;

-- Leaf Page에 Shipvia 정보도 볼 수 있게 해서 HEAP TALBE까지 가지 않아도 됨
CREATE NONCLUSTERED INDEX Orders_Index01
ON TestOrders(CustomerID) INCLUDE (Shipvia);

SELECT *
FROM TestOrders WITH(INDEX(Orders_Index01))
WHERE CustomerID = 'QUICK' AND ShipVia = 3;

-- 결론
-- NonClustered Index가 악영향을 주는 경우?
	-- 북마크 룩업이 심각한 부하를 야기할 때
-- 대안
	-- 옵션 1) Covered Index(검색할 모든 컬럼을 포함하겠다.)
	-- 옵션 2) Index에 Include로 힌트를 남긴다.
	-- 옵션 3) Clustered 고려 (단, 1번만 사용할 수 있는 궁극기) -> NonClustered에 악영향을 줄 수 있음




------------------

-- 복합 인덱스 컬럼 순서
-- Index(A, B, C)

DROP TABLE TestOrders;

SET STATISTICS TIME ON;
SET STATISTICS IO ON;
SET STATISTICS PROFILE ON;

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
SET STATISTICS PROFILE OFF;

-- Leaf Page 탐색은 여전히 존재한다.

SELECT *
INTO TestOrders
FROM Orders;

GO
DECLARE @i INT = 1;
DECLARE @emp INT;
SELECT @emp = MAX(employeeID) FROM Orders;

-- 더미 데이터를 엄청 늘린다

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

-- 두개 비교
SELECT *
FROM TestOrders WITH(INDEX(idx_emp_ord))
WHERE EmployeeID = 1 AND OrderDate = '19970101';

SELECT *
FROM TestOrders WITH(INDEX(idx_ord_imp))
WHERE EmployeeID = 1 AND OrderDate = '19970101';

-- 직접 살펴보자
SELECT *
FROM TestOrders
ORDER BY EmployeeID, OrderDate;

SELECT *
FROM TestOrders
ORDER BY OrderDate, EmployeeID;

-- 범위로 찾는다면?
SELECT *
FROM TestOrders WITH(INDEX(idx_emp_ord))
WHERE EmployeeID = 1 AND OrderDate BETWEEN '19970101' AND '19970103';

SELECT *
FROM TestOrders WITH(INDEX(idx_ord_imp))
WHERE EmployeeID = 1 AND OrderDate BETWEEN '19970101' AND '19970103';

-- Index(a, b, c)로 구성되었을 때, 선행에 between 사용 -> 후행은 인덱스 기능 상실

-- Between 범위가 작을 때 -> IN-LIST 로 대체하는 것을 고려 (사실상 여러번 = )
SELECT *
FROM TestOrders WITH(INDEX(idx_ord_imp))
WHERE EmployeeID = 1 AND OrderDate IN('19970101','19970102','19970103');

-- 오늘의 결론 --
-- 복합 컬럼 인덱스 (선행, 후행) 순서가 영향을 줄 수 있음
-- BETWEEN, 부등호 선행에 들어가면, 후행은 인덱스 기능을 상실
-- BETWEEN 범위가 적으면 IN-LIST 로 대체하면 좋은 경우도 있다. (선행에 BETWEEN)
-- 선행이 =, 후행이 BETWEEN이면 아무런 문제가 없기 때문에 IN-LIST X



-- 조인 원리
	-- 1) Nested Loop (NL) 조인
	-- 2) Merge (병합) 조인
	-- 3) Hash (해시) 조인

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

-- 오늘의 결론
-- NL 특징
-- 먼저 액세스한 (OUTER) 테이블의 로우를 차례 차례 -> (INNER) 테이블에 랜덤 엑세스
-- (INNER) 테이블에 인덱스가 없으면 노답
-- 부분범위 처리에 좋다 (ex. TOP 5)


-- Merge(병합) 조인