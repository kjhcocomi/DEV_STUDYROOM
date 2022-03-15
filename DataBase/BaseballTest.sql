USE BaseballData;

/*
SELECT nameFirst , nameLast, birthYear, birthCountry, weight
FROM players
WHERE (birthCountry != 'USA' OR birthYear = 1974) AND weight > 185;

SELECT *
FROM players
WHERE birthCity LIKE '%New york';

-- % : 아무 문자열이나 올 수 있는 조커카드
-- _ : 하나의 문자만 올 수 있음
*/

/*

-- TOP : tsql에서만 사용가능, 상위 ? 몇명 출력
-- PERCENT : 상위 ? 퍼센트 출력

SELECT TOP 1 PERCENT *
FROM players
WHERE birthYear IS NOT NULL
ORDER BY birthYear DESC, birthMonth DESC, birthDay DESC;


-- 100 ~ 100 + 100 출력

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
		WHEN 1 THEN N'겨울'
		WHEN 2 THEN N'겨울'
		WHEN 3 THEN N'봄'
		WHEN 4 THEN N'봄'
		WHEN 5 THEN N'봄'
		WHEN 6 THEN N'여름'
		WHEN 7 THEN N'여름'
		WHEN 8 THEN N'여름'
		WHEN 9 THEN N'가을'
		WHEN 10 THEN N'가을'
		WHEN 11 THEN N'가을'
		WHEN 12 THEN N'겨울'
		ELSE N'몰라용'
	END AS birthSeason
FROM players;
*/

/*
SELECT *,
	CASE
		WHEN birthMonth <=2 THEN N'겨울'
		WHEN birthMonth <=5 THEN N'봄'
		WHEN birthMonth <=8 THEN N'여름'
		WHEN birthMonth <=11 THEN N'가을'
		ELSE N'겨울'
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

-- * 붙일 수 있는 애는 COUNT가 유일

SELECT COUNT(birthYear)
FROM players;

-- 집계함수는 null을 무시 !!

SELECT DISTINCT birthYear, birthMonth, birthDay
FROM players
ORDER BY birthYear;

-- DISTINCT : 중복되지 않는것만 ( 여러개면 여러개가 다 같아야 중복으로 인정)

SELECT COUNT(DISTINCT birthCity)
FROM players;

-- 선수들의 평균 weight (pound)

SELECT AVG(weight)
FROM players;

-- 선수들의 평균 weight (pound) (NULL이면 0으로 가정)

SELECT AVG(CASE WHEN weight IS NULL THEN 0 ELSE weight END)
FROM players;

-- MIN MAX
-- MIN MAX 는 문자열, 날짜에도 사용 가능
SELECT MIN(weight) as minweight, MAX(weight) as maxweight
FROM players;

*/

/*

-- playerID (선수 ID)
-- yearID (시즌 년도)
-- teamID (팀 명칭)
-- G_batting (출전경기 + 타석)

-- AB : 타수
-- H : 안타
-- R : 출루
-- 2B : 2루타
-- 3B : 3루타
-- HR : 홈런
-- BB : 볼넷

SELECT *
FROM batting

-- 1) 보스턴 소속 선수들의 정보들만 출력
-- 2) 보스턴 소속 선수들의 수는 몇명? (중복은 제거)
-- 3) 보스턴 팀이 2004년에 친 홈런 개수
-- 4) 보스턴 팀 소속으로 단일 년도 최다 홈런을 친 사람의 정보

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

-- 순서 : FROM - WHERE - ... - SELECT - ORDER BY

-- 단일 년도에 가장 많은 홈런을 날린 팀
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

-- INSERT INTO [테이블명] VALUES [값, ...]

INSERT INTO salaries
VALUES (2020, 'KOR', 'NL', 'kjh', 9000000);

-- INSERT INTO [테이블명] (열, ...) VALUES [값, ...]

INSERT INTO salaries (yearID, teamID, playerID, lgID)
VALUES(2020, 'KOR', 'kjh3', 'NL');

-- DELETE FROM [테이블명] WHERE [조건]

DELETE FROM salaries
WHERE yearID >= 2020

-- UPDATE [테이블명] SET [열 = 값, ] WHERE [조건]

UPDATE salaries
SET salary = salary * 2
WHERE teamID = 'KOR'
*/

/*
-- SubQuery
-- SQL 명령문 안에 지정하는 하부 SELECT

-- 연봉이 역대급으로 높은 선수의 정보를 추출
SELECT *
FROM salaries
ORDER BY salary DESC;

-- rodrial01 는 누구?
SELECT *
FROM players
WHERE playerID = 'rodrial01'

-- 한번에 하기
-- 단일행 서브쿼리
SELECT *
FROM players
WHERE playerID = (SELECT TOP 1 playerID FROM salaries ORDER BY salary DESC);

-- 다중행 (중복되면 하나만 인정)
SELECT *
FROM players
WHERE playerID IN (SELECT TOP 10 playerID FROM salaries ORDER BY salary DESC);

-- 서브쿼리는 WHERE에서 가장 많이 사용되지만, 나머지 구문에서도 사용 가능

SELECT (SELECT COUNT(*) FROM players) AS playerCount, (SELECT COUNT(*) FROM batting) AS battingCount

-- INSERT 에서도 사용 가능
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

-- 상관 관계 서브쿼리
-- EXISTS, NOT EXISTS

-- 포스트 시즌 타격에 참여한 선수들 목록
SELECT *
FROM players
WHERE playerID IN (SELECT playerID FROM battingpost);

SELECT *
FROM players
WHERE EXISTS (SELECT playerID FROM battingpost WHERE battingpost.playerID = players.playerID)
*/

-- JOIN(결합)

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

-- CROSS JOIN (교차 결합)

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

-- INNER JOIN (두 개의 테이블을 가로로 결함 + 결합 기준을 ON으로)
-- playerID가 players, salaries 양쪽에 다 있고 일치하는 애들을 결합

SELECT *
FROM players AS p
	INNER JOIN salaries AS s
	ON p.playerID = s.playerID;

-- OUTER JOIN (외부 결합)
	-- LEFT / RIGHT
	-- 어느 한쪽에만 존재하는 데이터 -> 정책은 어떻게 할 것?

-- LEFT JOIN (두 개의 테이블을 가로로 결함 + 결합 기준을 ON으로)
-- playerID 가 왼쪽(players)에 있으면 무조건 표시, 오른쪽(salaries)에 없으면 오른쪽 정보는 NULL로 채움

SELECT *
FROM players AS p
	LEFT JOIN salaries AS s
	ON p.playerID = s.playerID;

-- RIGHT JOIN (두 개의 테이블을 가로로 결함 + 결합 기준을 ON으로)
-- playerID 가 오른쪽(salaries)에 있으면 무조건 표시, 왼쪽(players)에 없으면 왼쪽 정보는 NULL로 채움

SELECT *
FROM players AS p
	RIGHT JOIN salaries AS s
	ON p.playerID = s.playerID;

*/

/*
-- 변수

USE BaseballData;

DECLARE @i AS INT = 10;

DECLARE @j AS INT;
SET @j = 10;

-- 예제) 역대 최고 연봉을 받은 선수 이름

DECLARE @firstName AS NVARCHAR(15);
DECLARE @lastName AS NVARCHAR(15);

SET @firstName = (SELECT TOP 1 nameFirst
					FROM players AS p
						INNER JOIN salaries AS s
						ON p.playerID = s.playerID
					ORDER BY s.salary DESC);

-- SQL SERVER에서만 지원

SELECT TOP 1 @firstName = p.nameFirst, @lastName = p.nameLast
FROM players AS p
	INNER JOIN salaries AS s
	ON p.playerID = s.playerID
ORDER BY s.salary DESC;

SELECT @firstName, @lastName;

-- 배치

-- }

GO

-- 배치를 이용해 변수의 유효범위 설정 가능 { }

DECLARE @i AS INT = 10;

-- 배치는 하나의 묶음으로 분석되고 실행되는 명령어 집합

SELECT *
FOM players;

GO

SELECT *
FROM salaries;

-- 흐름 제어

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

-- 테이블 변수
-- 임시로 사용할 테이블을 변수로 만들 수 있다
-- DECLARE 사용 -> tempdb 데이터베이스에 임시 저장

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

-- 윈도우 함수
-- 행들의 서브 집합을 대상으로, 각 행별로 계산을 해서 스칼라(단일 고정)값을 출력하는 함수

-- 느낌상 GROUPING 이랑 비슷?

SELECT *
FROM salaries
ORDER BY salary DESC;

SELECT playerID, MAX(salary)
FROM salaries
GROUP BY playerID
ORDER BY MAX(salary) DESC;

-- ~OVER([PARTITION] [ORDER BY] [ROWS])

-- 전체 데이터를 연봉 순서로 나열하고, 순위 표기

SELECT *,
	ROW_NUMBER() OVER (ORDER BY salary DESC), -- 행 번호
	RANK() OVER (ORDER BY salary DESC), -- 랭킹
	DENSE_RANK() OVER (ORDER BY salary DESC), -- 랭킹
	NTILE(100) OVER (ORDER BY salary DESC) -- 상위 몇 %
FROM salaries;

-- playerID 별 순위를 따로 하고 싶다면

SELECT *,
	RANK() OVER (PARTITION BY playerID ORDER BY salary DESC)
FROM salaries
ORDER BY playerID;

-- LAG(바로 이전), LEAD(바로 다음)
SELECT *,
	RANK() OVER (PARTITION BY playerID ORDER BY salary DESC),
	LAG(salary) OVER (PARTITION BY playerID ORDER BY salary DESC) AS prevSalary,
	LEAD(salary) OVER (PARTITION BY playerID ORDER BY salary DESC) AS nextSalary
FROM salaries
ORDER BY playerID;

-- FIRST_VALUE, LAST_VALUE
-- FRAME : FIRST ~ CURRENT (기본값)
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