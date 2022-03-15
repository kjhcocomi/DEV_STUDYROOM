USE BaseballData;

/*
SELECT nameFirst , nameLast, birthYear, birthCountry, weight
FROM players
WHERE (birthCountry != 'USA' OR birthYear = 1974) AND weight > 185;

SELECT *
FROM players
WHERE birthCity LIKE '%New york';

-- % : �ƹ� ���ڿ��̳� �� �� �ִ� ��Ŀī��
-- _ : �ϳ��� ���ڸ� �� �� ����
*/

/*

-- TOP : tsql������ ��밡��, ���� ? ��� ���
-- PERCENT : ���� ? �ۼ�Ʈ ���

SELECT TOP 1 PERCENT *
FROM players
WHERE birthYear IS NOT NULL
ORDER BY birthYear DESC, birthMonth DESC, birthDay DESC;


-- 100 ~ 100 + 100 ���

SELECT *
FROM players
WHERE birthYear IS NOT NULL
ORDER BY birthYear DESC, birthMonth DESC, birthDay DESC
OFFSET 100 ROWS FETCH NEXT 100 ROWS ONLY;

*/

/*

SELECT 2021 - birthYear AS koreanAge, nameFirst, nameLast
FROM players
WHERE deathYear IS NULL AND birthYear IS NOT NULL AND 2021 - birthYear <= 80
ORDER BY koreanAge ;

*/

/*
SELECT nameFirst + ' ' + nameLast AS fullName
FROM players;
*/

/*
SELECT *,
	CASE birthMonth
		WHEN 1 THEN N'�ܿ�'
		WHEN 2 THEN N'�ܿ�'
		WHEN 3 THEN N'��'
		WHEN 4 THEN N'��'
		WHEN 5 THEN N'��'
		WHEN 6 THEN N'����'
		WHEN 7 THEN N'����'
		WHEN 8 THEN N'����'
		WHEN 9 THEN N'����'
		WHEN 10 THEN N'����'
		WHEN 11 THEN N'����'
		WHEN 12 THEN N'�ܿ�'
		ELSE N'�����'
	END AS birthSeason
FROM players;
*/

/*
SELECT *,
	CASE
		WHEN birthMonth <=2 THEN N'�ܿ�'
		WHEN birthMonth <=5 THEN N'��'
		WHEN birthMonth <=8 THEN N'����'
		WHEN birthMonth <=11 THEN N'����'
		ELSE N'�ܿ�'
	END AS birthSeason
FROM players;
*/

/*

-- COUNT
-- SUM
-- AVG 
-- MIN
-- MAX

SELECT COUNT(*)
FROM players;

-- * ���� �� �ִ� �ִ� COUNT�� ����

SELECT COUNT(birthYear)
FROM players;

-- �����Լ��� null�� ���� !!

SELECT DISTINCT birthYear, birthMonth, birthDay
FROM players
ORDER BY birthYear;

-- DISTINCT : �ߺ����� �ʴ°͸� ( �������� �������� �� ���ƾ� �ߺ����� ����)

SELECT COUNT(DISTINCT birthCity)
FROM players;

-- �������� ��� weight (pound)

SELECT AVG(weight)
FROM players;

-- �������� ��� weight (pound) (NULL�̸� 0���� ����)

SELECT AVG(CASE WHEN weight IS NULL THEN 0 ELSE weight END)
FROM players;

-- MIN MAX
-- MIN MAX �� ���ڿ�, ��¥���� ��� ����
SELECT MIN(weight) as minweight, MAX(weight) as maxweight
FROM players;

*/

/*

-- playerID (���� ID)
-- yearID (���� �⵵)
-- teamID (�� ��Ī)
-- G_batting (������� + Ÿ��)

-- AB : Ÿ��
-- H : ��Ÿ
-- R : ���
-- 2B : 2��Ÿ
-- 3B : 3��Ÿ
-- HR : Ȩ��
-- BB : ����

SELECT *
FROM batting

-- 1) ������ �Ҽ� �������� �����鸸 ���
-- 2) ������ �Ҽ� �������� ���� ���? (�ߺ��� ����)
-- 3) ������ ���� 2004�⿡ ģ Ȩ�� ����
-- 4) ������ �� �Ҽ����� ���� �⵵ �ִ� Ȩ���� ģ ����� ����

-- 1)
SELECT *
FROM batting
WHERE teamID = 'BOS';

-- 2)
SELECT COUNT(DISTINCT playerID) AS CNT
FROM batting
WHERE teamID = 'BOS';

-- 3)
SELECT SUM(HR)
FROM batting
WHERE teamID = 'BOS' AND yearID = 2004

-- 4)
SELECT TOP(1) *
FROM batting
WHERE teamID = 'BOS'
ORDER BY HR DESC

SELECT *
FROM players
WHERE playerID ='ortizda01'

*/

/*
SELECT teamID, SUM(HR) AS HR_CNT
FROM batting
WHERE yearID = 2004
GROUP BY teamID
HAVING SUM(HR) >= 200
ORDER BY HR_CNT DESC

-- ���� : FROM - WHERE - ... - SELECT - ORDER BY

-- ���� �⵵�� ���� ���� Ȩ���� ���� ��
SELECT teamID, yearID, SUM(HR) AS HR_CNT
FROM batting
GROUP BY teamID, yearID
ORDER BY HR_CNT DESC
*/

-- INSERT DELETE UPDATE

/*
SELECT *
FROM salaries
ORDER BY yearID DESC;

-- INSERT INTO [���̺��] VALUES [��, ...]

INSERT INTO salaries
VALUES (2020, 'KOR', 'NL', 'kjh', 9000000);

-- INSERT INTO [���̺��] (��, ...) VALUES [��, ...]

INSERT INTO salaries (yearID, teamID, playerID, lgID)
VALUES(2020, 'KOR', 'kjh3', 'NL');

-- DELETE FROM [���̺��] WHERE [����]

DELETE FROM salaries
WHERE yearID >= 2020

-- UPDATE [���̺��] SET [�� = ��, ] WHERE [����]

UPDATE salaries
SET salary = salary * 2
WHERE teamID = 'KOR'
*/

/*
-- SubQuery
-- SQL ��ɹ� �ȿ� �����ϴ� �Ϻ� SELECT

-- ������ ��������� ���� ������ ������ ����
SELECT *
FROM salaries
ORDER BY salary DESC;

-- rodrial01 �� ����?
SELECT *
FROM players
WHERE playerID = 'rodrial01'

-- �ѹ��� �ϱ�
-- ������ ��������
SELECT *
FROM players
WHERE playerID = (SELECT TOP 1 playerID FROM salaries ORDER BY salary DESC);

-- ������ (�ߺ��Ǹ� �ϳ��� ����)
SELECT *
FROM players
WHERE playerID IN (SELECT TOP 10 playerID FROM salaries ORDER BY salary DESC);

-- ���������� WHERE���� ���� ���� ��������, ������ ���������� ��� ����

SELECT (SELECT COUNT(*) FROM players) AS playerCount, (SELECT COUNT(*) FROM batting) AS battingCount

-- INSERT ������ ��� ����
SELECT * 
FROM salaries
ORDER BY yearID DESC

INSERT INTO salaries
VALUES (2020, 'KOR', 'NL', 'kjhkjh', (SELECT MAX(salary) FROM salaries) + 100)

INSERT INTO salaries
SELECT 2020, 'KOR', 'NL', 'kjhkjh2', (SELECT MAX(salary) FROM salaries) + 200

/*
INSERT INTO salaries_temp
SELECT yearID, playerID, salary
FROM salaries;

SELECT * 
FROM salaries_temp;
*/

-- ��� ���� ��������
-- EXISTS, NOT EXISTS

-- ����Ʈ ���� Ÿ�ݿ� ������ ������ ���
SELECT *
FROM players
WHERE playerID IN (SELECT playerID FROM battingpost);

SELECT *
FROM players
WHERE EXISTS (SELECT playerID FROM battingpost WHERE battingpost.playerID = players.playerID)
*/

-- JOIN(����)

/*
USE GameDB;

CREATE TABLE testA
(
	a INTEGER
)

CREATE TABLE testB
(
	b VARCHAR(10)
)

-- A(1, 2, 3)
INSERT INTO testA VALUES(1);
INSERT INTO testA VALUES(2);
INSERT INTO testA VALUES(3);

-- B('A', 'B', 'C')
INSERT INTO testB VALUES('A');
INSERT INTO testB VALUES('B');
INSERT INTO testB VALUES('C');

-- CROSS JOIN (���� ����)

SELECT *
FROM testA
CROSS JOIN testB;

SELECT *
FROM testA, testB;
*/
----------------------

/*
USE BaseballData;

SELECT *
FROM players
ORDER BY playerID;
SELECT *
FROM salaries
ORDER BY playerID;

-- INNER JOIN (�� ���� ���̺��� ���η� ���� + ���� ������ ON����)
-- playerID�� players, salaries ���ʿ� �� �ְ� ��ġ�ϴ� �ֵ��� ����

SELECT *
FROM players AS p
	INNER JOIN salaries AS s
	ON p.playerID = s.playerID;

-- OUTER JOIN (�ܺ� ����)
	-- LEFT / RIGHT
	-- ��� ���ʿ��� �����ϴ� ������ -> ��å�� ��� �� ��?

-- LEFT JOIN (�� ���� ���̺��� ���η� ���� + ���� ������ ON����)
-- playerID �� ����(players)�� ������ ������ ǥ��, ������(salaries)�� ������ ������ ������ NULL�� ä��

SELECT *
FROM players AS p
	LEFT JOIN salaries AS s
	ON p.playerID = s.playerID;

-- RIGHT JOIN (�� ���� ���̺��� ���η� ���� + ���� ������ ON����)
-- playerID �� ������(salaries)�� ������ ������ ǥ��, ����(players)�� ������ ���� ������ NULL�� ä��

SELECT *
FROM players AS p
	RIGHT JOIN salaries AS s
	ON p.playerID = s.playerID;

*/

/*
-- ����

USE BaseballData;

DECLARE @i AS INT = 10;

DECLARE @j AS INT;
SET @j = 10;

-- ����) ���� �ְ� ������ ���� ���� �̸�

DECLARE @firstName AS NVARCHAR(15);
DECLARE @lastName AS NVARCHAR(15);

SET @firstName = (SELECT TOP 1 nameFirst
					FROM players AS p
						INNER JOIN salaries AS s
						ON p.playerID = s.playerID
					ORDER BY s.salary DESC);

-- SQL SERVER������ ����

SELECT TOP 1 @firstName = p.nameFirst, @lastName = p.nameLast
FROM players AS p
	INNER JOIN salaries AS s
	ON p.playerID = s.playerID
ORDER BY s.salary DESC;

SELECT @firstName, @lastName;

-- ��ġ

-- }

GO

-- ��ġ�� �̿��� ������ ��ȿ���� ���� ���� { }

DECLARE @i AS INT = 10;

-- ��ġ�� �ϳ��� �������� �м��ǰ� ����Ǵ� ��ɾ� ����

SELECT *
FOM players;

GO

SELECT *
FROM salaries;

-- �帧 ����

-- IF
GO
DECLARE @i AS INT = 1;

IF @I = 10
	PRINT('BINGO');
else
	print('NO');

IF @I = 10
BEGIN
	PRINT('BINGO');
	PRINT('BINGO');
END
else
BEGIN
	print('NO');
	print('NO');
END

-- WHILE

GO

DECLARE @i AS INT = 0;
WHILE @i <= 10
BEGIN
	SET @i = @i + 1;
	IF @i = 6 CONTINUE;
	PRINT @i;
END

-- ���̺� ����
-- �ӽ÷� ����� ���̺��� ������ ���� �� �ִ�
-- DECLARE ��� -> tempdb �����ͺ��̽��� �ӽ� ����

GO

DECLARE @test TABLE
(
	name VARCHAR(50) NOT NULL,
	salary INT NOT NULL
);

INSERT INTO @test
SELECT p.nameFirst + ' ' + p.nameLast, s.salary
FROM players as p
	INNER JOIN salaries AS s
	ON p.playerID = s.playerID

SELECT *
FROM @test;
*/

-- ������ �Լ�
-- ����� ���� ������ �������, �� �ະ�� ����� �ؼ� ��Į��(���� ����)���� ����ϴ� �Լ�

-- ������ GROUPING �̶� ���?

SELECT *
FROM salaries
ORDER BY salary DESC;

SELECT playerID, MAX(salary)
FROM salaries
GROUP BY playerID
ORDER BY MAX(salary) DESC;

-- ~OVER([PARTITION] [ORDER BY] [ROWS])

-- ��ü �����͸� ���� ������ �����ϰ�, ���� ǥ��

SELECT *,
	ROW_NUMBER() OVER (ORDER BY salary DESC), -- �� ��ȣ
	RANK() OVER (ORDER BY salary DESC), -- ��ŷ
	DENSE_RANK() OVER (ORDER BY salary DESC), -- ��ŷ
	NTILE(100) OVER (ORDER BY salary DESC) -- ���� �� %
FROM salaries;

-- playerID �� ������ ���� �ϰ� �ʹٸ�

SELECT *,
	RANK() OVER (PARTITION BY playerID ORDER BY salary DESC)
FROM salaries
ORDER BY playerID;

-- LAG(�ٷ� ����), LEAD(�ٷ� ����)
SELECT *,
	RANK() OVER (PARTITION BY playerID ORDER BY salary DESC),
	LAG(salary) OVER (PARTITION BY playerID ORDER BY salary DESC) AS prevSalary,
	LEAD(salary) OVER (PARTITION BY playerID ORDER BY salary DESC) AS nextSalary
FROM salaries
ORDER BY playerID;

-- FIRST_VALUE, LAST_VALUE
-- FRAME : FIRST ~ CURRENT (�⺻��)
SELECT *,
	RANK() OVER (PARTITION BY playerID ORDER BY salary DESC),
	FIRST_VALUE(salary) OVER (PARTITION BY playerID 
								ORDER BY salary DESC
								ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
								) AS best,
	LAST_VALUE(salary) OVER (PARTITION BY playerID 
								ORDER BY salary DESC
								ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
								) AS worst
FROM salaries
ORDER BY playerID;