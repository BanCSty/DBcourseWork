
# drop database if exists `Коттеджный посёлок`;
# create database `Коттеджный посёлок`;

use `Коттеджный посёлок`;

 drop table if exists `Строения на участках`;
 drop table if exists `Участки`;
 drop table if exists `Типовые проекты строений`;
 drop table if exists `Типовые проекты строений1`;
 
create table `Типовые проекты строений` (
	`№ проекта` varchar(5) not null primary key,
    `Название проекта` varchar(30) not null,
    `Общая площадь строения` int not null,
    `Стоимость руб.` int not null
);

insert into `Типовые проекты строений`
value 	('Ф102', 'Коттедж «Карелия»', 140, 1800000);

create table `Типовые проекты строений1` (
	`№ проекта` varchar(5) not null primary key,
    `Название проекта` varchar(30) not null,
    `Общая площадь строения` int not null,
    `Стоимость руб.` int not null
);
insert into `Типовые проекты строений1`
values 	
		('Ф105', 'Коттедж «Настюша»', 100, 1200000),
        ('Ф207', 'Баня «Бодрость»', 20, 460000);
  


create table `Участки` (
	`№ порядковый` int(5) not null primary key,
    `Площадь участка`int(5) not null,
    `Состояние` varchar(15) not null
);
insert into `Участки`
values 	(1001, 1500, 'Продан'),
		(1002, 1500, 'Забронирован'),
		(1003, 1200, 'Свободен'),
		(1004, 1800, 'Продан'),
		(1005, 1200, 'Свободен'),
		(1006, 1200,'Забронирован');

create table `Строения на участках` (
	`№ порядковый` int(5) not null,
    `№ проекта` varchar(5) not null,
    primary key(`№ порядковый`,`№ проекта`),
    foreign key(`№ порядковый`) references `Участки`(`№ порядковый`) on update cascade on delete restrict,
    foreign key(`№ проекта`) references `Типовые проекты строений`(`№ проекта`) on update cascade on delete restrict
);
# №4
Insert into `типовые проекты строений` 
Select * FROM `типовые проекты строений1`;
insert into `Строения на участках`
values 	
(1001, 'Ф102'),
(1001, 'Ф207'),
(1003, 'Ф102'),
(1004, 'Ф105'),
(1004, 'Ф207'); 

ALTER TABLE `типовые проекты строений`
ADD INDEX numProject(`№ проекта`);

ALTER TABLE `участки`
ADD INDEX numOrdinal(`№ порядковый`);

ALTER TABLE `строения на участках`
ADD INDEX numProject_numOrdinal(`№ порядковый`,`№ проекта`); #Здеь не имеет значения порядок атрибутов в индексе т.к. у них одинаковое значение кол-во строк в таблице

#№5 DROP – удалить таблицу «Типовые проекты строений1».
DROP table `Типовые проекты строений1`;

# №6. UPDATE – увеличить в поле «Стоимость» таблицы «Типовые проекты строений» стоимость на 10%.
Update `типовые проекты строений` set `Стоимость руб.` = `Стоимость руб.` * 1.1 where true;

# №7 DELETE – удалить данные по участку №1004 из всех таблиц
Start transaction;
Delete From `строения на участках` where `№ порядковый` = 1004;
Delete From `Участки` where `№ порядковый` = 1004;
commit;

# №8 SELECT – вывести на экран записи, содержащие следующие поля: 
# № проекта, Название проекта, Общая площадь, Стоимость для всех проектов, 
# стоимость которых находится в диапазоне от 1млн. руб. до 2млн. руб.
Select `№ проекта`, `Название проекта`,`Общая площадь строения`,`Стоимость руб.` from `типовые проекты строений` 
WHERE `Стоимость руб.` BETWEEN 1000000 AND 2000000;

# №9 SELECT – после задания порядкового № участка, вывести на экран записи, содержащие следующие поля:
# порядковый № участка, Площадь участка, Состояние, № проекта, Название проекта, Общая площадь, 
# Стоимость по каждому строению, находящемуся на этом участке.
SET @NUM = 1001;
SELECT A.`№ порядковый`, A.`Площадь участка`, A.`Состояние`, C.`№ проекта`, `Название проекта`, `Общая площадь строения`, `Стоимость руб.` FROM `участки` as A
INNER JOIN `строения на участках` as B ON B.`№ порядковый` = @NUM
INNER JOIN `типовые проекты строений` as C ON C.`№ проекта` = B.`№ проекта` and A.`№ порядковый` = @NUM 
order by(`Стоимость руб.`) asc;

# №10 SELECT – вывести на экран записи, содержащие следующие поля:
# № участка, Площадь участка, Состояние для всех участков, на которых нет никаких построек.
SELECT `№ порядковый`,`Площадь участка`,`Состояние` FROM `участки` as A
WHERE not exists (SELECT * FROM `строения на участках` where `№ порядковый` = A.`№ порядковый`);

# №11 SELECT – вывести на экран записи, содержащие следующие поля:
# № участка, Площадь участка, Состояние, Количество строений на участке, если это количество не меньше двух.
SELECT Y.`№ порядковый`,`Площадь участка`,`Состояние`, COUNT(Y.`№ порядковый`) as `Количетво строений на участке` FROM `участки` AS Y
INNER JOIN `строения на участках` AS S ON Y.`№ порядковый` = S.`№ порядковый`
GROUP BY Y.`№ порядковый` HAVING COUNT(Y.`№ порядковый`)>=2;


# №12 SELECT – вывести на экран запись – суммарную стоимость всех строений расположенных на всех участках.
SELECT Sum(`Стоимость руб.`) FROM `типовые проекты строений` AS A
INNER JOIN `строения на участках` AS B ON A.`№ проекта` = B.`№ проекта`;

# №13 SELECT – вывести на экран записи, содержащие следующие поля:
# № проекта, Название проекта, Общая площадь строения, Стоимость, Количество участков, 
# на которых возведены строения по данному проекту.
SELECT T.`№ проекта`,`Название проекта`,`Общая площадь строения`,`Стоимость руб.`, COUNT(S.`№ проекта`) AS `Количество участков`
FROM `типовые проекты строений` AS T INNER JOIN `строения на участках` AS S ON 
T.`№ проекта` = S.`№ проекта` GROUP BY 1;

# №14 SELECT – вывести на экран запись, содержащую следующие поля:
# № участка, Площадь участка, Состояние с максимальной ценой.
SELECT Y.`№ порядковый`, `Площадь участка`, `Состояние`, Max(
(Select SUM(`Стоимость руб.`) from `типовые проекты строений` as A, `строения на участках` as B WHERE 
A.`№ проекта` = B.`№ проекта` AND B.`№ порядковый` = Y.`№ порядковый`))
AS 'Стоимость' FROM `участки` AS Y;
