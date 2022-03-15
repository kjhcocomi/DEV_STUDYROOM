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

-- 복수의 테이블을 다루는 방법

-- 커리어 평균 연봉이 3000000 이상인 선수들의 playerID

SELECT playerID, AVG(salary) 
FROM salaries
GROUP BY playerID
HAVING AVG(salary)>= 3000000;

-- 12월에 태어난 선수들의 playerID

SELECT playerID, birthMonth
FROM players
WHERE birthMonth = 12;

-- [커리어 평균 연봉이 3000000 이상] || [12월에 태어난] 선수 (합집합)
-- UNION (중복 제거) UNION ALL (중복 허용)

SELECT playerID
FROM salaries
GROUP BY playerID
HAVING AVG(salary)>= 3000000
UNION ALL
SELECT playerID
FROM players
WHERE birthMonth = 12
ORDER BY playerID

-- [커리어 평균 연봉이 3000000 이상] && [12월에 태어난] 선수 (교집합)
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

-- [커리어 평균 연봉이 3000000 이상] - [12월에 태어난] 선수 (차집합)

SELECT playerID
FROM salaries
GROUP BY playerID
HAVING AVG(salary)>= 3000000
EXCEPT
SELECT playerID
FROM players
WHERE birthMonth = 12
ORDER BY playerID