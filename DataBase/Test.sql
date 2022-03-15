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

-- ������ ���̺��� �ٷ�� ���

-- Ŀ���� ��� ������ 3000000 �̻��� �������� playerID

SELECT playerID, AVG(salary) 
FROM salaries
GROUP BY playerID
HAVING AVG(salary)>= 3000000;

-- 12���� �¾ �������� playerID

SELECT playerID, birthMonth
FROM players
WHERE birthMonth = 12;

-- [Ŀ���� ��� ������ 3000000 �̻�] || [12���� �¾] ���� (������)
-- UNION (�ߺ� ����) UNION ALL (�ߺ� ���)

SELECT playerID
FROM salaries
GROUP BY playerID
HAVING AVG(salary)>= 3000000
UNION ALL
SELECT playerID
FROM players
WHERE birthMonth = 12
ORDER BY playerID

-- [Ŀ���� ��� ������ 3000000 �̻�] && [12���� �¾] ���� (������)
-- INTERSECT

SELECT playerID
FROM salaries
GROUP BY playerID
HAVING AVG(salary)>= 3000000
INTERSECT
SELECT playerID
FROM players
WHERE birthMonth = 12
ORDER BY playerID

-- [Ŀ���� ��� ������ 3000000 �̻�] - [12���� �¾] ���� (������)

SELECT playerID
FROM salaries
GROUP BY playerID
HAVING AVG(salary)>= 3000000
EXCEPT
SELECT playerID
FROM players
WHERE birthMonth = 12
ORDER BY playerID