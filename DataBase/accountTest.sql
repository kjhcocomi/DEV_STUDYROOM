
-- 데이터베이스 만들기
--CREATE DATABASE GameDB;

USE GameDB;

-- 테이블 생성(CREATE)/ 삭제(DROP) / 변경(ALTER)

-- CREATE TABLE 테이블명 (열이름 자료형 [DEFAULT 기본값] [NULL | NOT NULL], ... )

CREATE TABLE accounts(
	accountID INTEGER NOT NULL,
	accountName VARCHAR(10) NOT NULL,
	coins INTEGER DEFAULT 0,
	createdTime DATETIME
);

SELECT *
FROM accounts;

-- 테이블 삭제
DROP TABLE accounts;

-- 테이블 변경
-- 열 추가(ADD)/ 삭제(DROP)/변경(ALTER)

-- 열 추가
ALTER TABLE accounts
ADD lastEnterTime DATETIME;

-- 열 삭제
ALTER TABLE accounts
DROP COLUMN lastEnterTime;

-- 변경
ALTER TABLE accounts
ALTER COLUMN accountName VARCHAR(20) NOT NULL;

-- 제약 (CONSTRAINT) 추가/삭제
-- NOT NULL
-- UNIQUE
-- PRIMARY KEY
-- FOREIGN KEY

ALTER TABLE accounts
ADD PRIMARY KEY (accountID);

ALTER TABLE accounts
ADD CONSTRAINT PK_Account PRIMARY KEY (accountID);

ALTER TABLE accounts
DROP CONSTRAINT PK_Account;

-- 인덱스 CREATE INDEX / DROP INDEX

CREATE INDEX i1 ON accounts(accountName);

DROP INDEX accounts.i1;

-------

USE GameDB;

SELECT *
FROM accounts;

DELETE accounts;

INSERT INTO accounts
VALUES (4, 'kjh2', 150, '20220311 15:18')

INSERT INTO accounts
VALUES (4, 'kjh2', 150, GETUTCDATE())

-- 트랜잭션
-- 트랜잭션 명시하지 않으면 자동으로 COMMIT

-- BEGIN TRAN;
-- COMMIT;
-- ROLLBACK;

-- EX)
-- 메일 쓰기(BRGIN TRAN)
-- 보낸다 (COMMIT)
-- 취소한다 (ROLLBACK)

-- 성공/실패 여부에 따라 COMMIT ( = COMMIT을 수동으로 하겠다)
BEGIN TRAN;
	INSERT INTO accounts VALUES (5, 'kjh3', 2000, GETUTCDATE())
ROLLBACK;

BEGIN TRAN;
	INSERT INTO accounts VALUES (5, 'kjh3', 2000, GETUTCDATE())
COMMIT;

-- 응용
BEGIN TRY
	BEGIN TRAN;
		INSERT INTO accounts VALUES (4, 'kjh4', 2000, GETUTCDATE())
		INSERT INTO accounts VALUES (6, 'kjh6', 2000, GETUTCDATE())
	COMMIT;
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 -- 현재 활성화된 트랜잭션 수를 반환
		ROLLBACK
	PRINT('롤백')
END CATCH

-- TRAN 사용할 때 주의할 점
-- TRAN 안에는 꼭 !!! 원자적으로 실행될 애들만 넣자
-- 성능적인 문제

SELECT *
FROM accounts;

BEGIN TRAN;
	INSERT INTO accounts VALUES (1, 'kjh1', 2000, GETUTCDATE())
ROLLBACK;
