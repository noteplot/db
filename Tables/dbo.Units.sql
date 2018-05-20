SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, QUOTED_IDENTIFIER, CONCAT_NULL_YIELDS_NULL ON
SET NUMERIC_ROUNDABORT OFF
GO

CREATE TABLE dbo.Units
( 
	UnitID               bigint IDENTITY ( 1,1 ) ,
	UnitShortName        nvarchar(24)  NOT NULL ,
	UnitName             nvarchar(48)  NOT NULL ,
	UnitGroupID          bigint  NOT NULL ,
	LoginID              bigint  NULL ,
	CONSTRAINT PK_Units PRIMARY KEY  CLUSTERED (UnitID ASC),
	CONSTRAINT FK_Units_UnitGroups FOREIGN KEY (UnitGroupID) REFERENCES dbo.UnitGroups(UnitGroupID),
CONSTRAINT FK_Units_Logins FOREIGN KEY (LoginID) REFERENCES dbo.Logins(LoginID)
)
go

/*
НУЛЕВОЙ UNITID - для строковых параметров, которые НЕ редактируются
SET IDENTITY_INSERT Units ON
GO
INSERT INTO dbo.Units (UnitID, UnitGroupID, UnitName, UnitShortName,LoginID) VALUES (0, 1, N'', N'',0)
SET IDENTITY_INSERT Units OFF
GO

НУЛЕВОЙ ЛОГИН!!!


UPDATE dbo.Units
SET LoginID = 0

*/
SET IDENTITY_INSERT Units ON
GO
-- Обшее
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (1, 1, N'шт.', N'штуки')

-- Время

INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (2, 2, N'Академический час', N'Ак. час')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (3, 2, N'Век', N'Век')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (4, 2, N'Вигилия', N'Вигилия')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (5, 2, N'Гигагод', N'Гигагод')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (6, 2, N'Год', N'Год')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (7, 2, N'Декада', N'Декада')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (8, 2, N'Десятилетие', N'Десятилетие')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (9, 2, N'Индикт', N'Индикт')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (10, 2, N'Йом', N'Йом')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (11, 2, N'Квартал', N'Квартал')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (12, 2, N'Месяц', N'Месяц')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (13, 2, N'Метонов цикл', N'Метонов цикл')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (14, 2, N'Минута', N'Минута')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (15, 2, N'Неделя', N'Неделя')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (16, 2, N'Полугодие', N'Полугодие')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (17, 2, N'Сутки', N'Сутки')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (18, 2, N'Час', N'Час')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (19, 2, N'Человеко-час', N'Человеко-час')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (20, 2, N'Эра', N'Эра')
GO

-- Вязкость
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (21, 3, N'Градус Энглера', N'Градус Энглера')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (22, 3, N'Пуаз', N'Пуаз')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (23, 3, N'Стокс', N'Стокс')
GO

--Давление
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (24, 4, N'Атмосфера', N'Атмосфера')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (25, 4, N'Бар', N'Бар')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (26, 4, N'Бария', N'Бария')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (27, 4, N'Дюйм водяного столба', N'Дюйм вод. ст.')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (28, 4, N'Дюйм ртутного столба', N'Дюйм рт. столба')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (29, 4, N'Миллиметр водяного столба', N'мм вод. столба')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (30, 4, N'Миллиметр ртутного столба', N'мм рт. столба')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (31, 4, N'Паскаль', N'Паскаль', N'Па')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (32, 4, N'Планковское давление', N'Планк.давл.')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (33, 4, N'Пьеза', N'Пьеза')
INSERT INTO Units (UnitID, UnitGroupID, UnitName, UnitShortName) VALUES (34, 4, N'Фунт на квадратный дюйм', N'Фунт на кв.дюйм')
GO
SET IDENTITY_INSERT Units OFF
GO
