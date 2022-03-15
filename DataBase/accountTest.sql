
-- �����ͺ��̽� �����
--CREATE DATABASE GameDB;

USE GameDB;

-- ���̺� ����(CREATE)/ ����(DROP) / ����(ALTER)

-- CREATE TABLE ���̺�� (���̸� �ڷ��� [DEFAULT �⺻��] [NULL | NOT NULL], ... )

CREATE TABLE accounts(
	accountID INTEGER NOT NULL,
	accountName VARCHAR(10) NOT NULL,
	coins INTEGER DEFAULT 0,
	createdTime DATETIME
);

SELECT *
FROM accounts;

-- ���̺� ����
DROP TABLE accounts;

-- ���̺� ����
-- �� �߰�(ADD)/ ����(DROP)/����(ALTER)

-- �� �߰�
ALTER TABLE accounts
ADD lastEnterTime DATETIME;

-- �� ����
ALTER TABLE accounts
DROP COLUMN lastEnterTime;

-- ����
ALTER TABLE accounts
ALTER COLUMN accountName VARCHAR(20) NOT NULL;

-- ���� (CONSTRAINT) �߰�/����
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

-- �ε��� CREATE INDEX / DROP INDEX

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

-- Ʈ�����
-- Ʈ����� ������� ������ �ڵ����� COMMIT

-- BEGIN TRAN;
-- COMMIT;
-- ROLLBACK;

-- EX)
-- ���� ����(BRGIN TRAN)
-- ������ (COMMIT)
-- ����Ѵ� (ROLLBACK)

-- ����/���� ���ο� ���� COMMIT ( = COMMIT�� �������� �ϰڴ�)
BEGIN TRAN;
	INSERT INTO accounts VALUES (5, 'kjh3', 2000, GETUTCDATE())
ROLLBACK;

BEGIN TRAN;
	INSERT INTO accounts VALUES (5, 'kjh3', 2000, GETUTCDATE())
COMMIT;

-- ����
BEGIN TRY
	BEGIN TRAN;
		INSERT INTO accounts VALUES (4, 'kjh4', 2000, GETUTCDATE())
		INSERT INTO accounts VALUES (6, 'kjh6', 2000, GETUTCDATE())
	COMMIT;
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 -- ���� Ȱ��ȭ�� Ʈ����� ���� ��ȯ
		ROLLBACK
	PRINT('�ѹ�')
END CATCH

-- TRAN ����� �� ������ ��
-- TRAN �ȿ��� �� !!! ���������� ����� �ֵ鸸 ����
-- �������� ����

SELECT *
FROM accounts;

BEGIN TRAN;
	INSERT INTO accounts VALUES (1, 'kjh1', 2000, GETUTCDATE())
ROLLBACK;
