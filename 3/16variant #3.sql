drop database if exists `Коттеджный посёлок`;
create database `Коттеджный посёлок`;
use `Коттеджный посёлок`;

 drop table if exists `Строения на участках`;
 drop table if exists `Участки`;
 drop table if exists `Типовые проекты строений`;


create table `Типовые проекты строений` (
	`№ проекта` varchar(5) not null primary key,
    `Название проекта` varchar(30) not null,
    `Общая площадь строения` int not null,
    `Стоимость руб.` int not null
);

insert into `Типовые проекты строений`
values 	('Ф102', 'Коттедж «Карелия»', 140, 1800000),
		('Ф105', 'Коттедж «Настюша»', 100, 1200000),
        ('Ф207', 'Баня «Бодрость»', 20, 460000);


create table `Участки` (
	`№ порядковый` int(5) not null primary key,
    `Площадь участка`int(5) not null,
    `Состояние` varchar(15) not null,
    `Количество строений на участке` int(3) default 0
);

insert into `Участки`
values 	(1001, 1500, 'Продан', 0),
		(1002, 1500, 'Забронирован', 0),
		(1003, 1200, 'Свободен', 0),
		(1004, 1800, 'Продан', 0),
		(1005, 1200, 'Свободен', 0),
		(1006, 1200,'Забронирован', 0);
   
create table `Строения на участках` (
	`№ порядковый` int(5) not null,
    `№ проекта` varchar(5) not null,
    primary key(`№ порядковый`,`№ проекта`),
    foreign key(`№ порядковый`) references `Участки`(`№ порядковый`) on update cascade on delete restrict,
    foreign key(`№ проекта`) references `Типовые проекты строений`(`№ проекта`) on update cascade on delete restrict
);

insert into `Строения на участках`
values 	
(1001, 'Ф102'),
(1001, 'Ф207'),
(1003, 'Ф102'),
(1004, 'Ф105'),
(1004, 'Ф207');
  

# №2 Хранимую функцию, которая использует данные из таблицы «Строения на участках» и подсчитывает общее количество строений на указанном участке.
DROP FUNCTION IF EXISTS Task2;
delimiter $$
create function Task2(num int) returns int
LANGUAGE SQL
DETERMINISTIC
begin
	declare result int;
    select Count(*) into result from `Строения на участках` where `№ порядковый` = num; 
	return result;
end$$
delimiter ;
Select Task2(1001); -- output 2

# №3 Хранимую процедуру, которая использует хранимую функцию, созданную в предыдущем пункте, 
# для заполнения полей в столбце «Количество строений на участке» по всем записям таблицы «Участки».
DROP procedure IF EXISTS Task3;
delimiter $
create procedure Task3()
LANGUAGE SQL
DETERMINISTIC
begin
	update `Участки` AS A, `Строения на участках` AS B set A.`Количество строений на участке` = Task2(B.`№ порядковый`)
	where A.`№ порядковый` =B.`№ порядковый`;
end$
delimiter ;

call Task3();
Select * From `Участки`;
update `Участки` set `Количество строений на участке` = 0;

# №4 Хранимую процедуру, которая реализует задание пункта 3, но с использование курсора.
DROP PROCEDURE IF EXISTS task4;
delimiter $
CREATE PROCEDURE task4() 
BEGIN
	Declare numbers, itog int;
	Declare done int;
 
	declare cur1 CURSOR for select `№ порядковый`, Count(*) from `строения на участках` group by(`№ порядковый`);

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done=1;
	OPEN cur1;
	WHILE done = 0 DO
		FETCH cur1 INTO numbers;
		update `Участки` set `Количество строений на участке` = itog where `№ порядковый` = numbers;
	END WHILE;
	CLOSE cur1;
END$
delimiter ;
call task4();
select * From `Участки`;
  
# №5 При удалении записи из таблицы «Строения на участках» требуется уменьшить на 
# единицу значение в соответствующем поле столбца «Количество строений на участке» таблицы «Участки»;
Drop trigger if exists Task5_DeleteTrig;
DELIMITER $
CREATE TRIGGER Task5_DeleteTrig
AFTER DELETE
   ON `строения на участках` FOR EACH ROW
	BEGIN
		update `Участки` set `Количество строений на участке` = `Количество строений на участке` - 1
		where `№ порядковый` = OLD.`№ порядковый`;
	END; $
DELIMITER ;
delete from `строения на участках` where `№ порядковый` = 1003;
Select * From `Участки`;

# №6 При добавлении записи в таблицу «Строения на участках» требуется увеличить на единицу 
# значение соответствующего поля столбца «Количество строений на участке» таблицы «Участки»;
Drop trigger if exists Task6_AddTrig;
delimiter $
Create trigger Task6_AddTrig after insert on `строения на участках`
for each row
	begin
		update `Участки` set `Количество строений на участке` = `Количество строений на участке` + 1 
		where `№ порядковый` = New.`№ порядковый`;
	end; $
delimiter ;
insert into `строения на участках` 
value (1003, 'Ф102');
select * from `Участки`;

# 7 При обновлении записи в таблице «Строения на участках» требуется выполнить пункт 5 для необновленной (старой) 
# записи таблицы «Строения на участках», а затем выполнить пункт 6 для обновленной (новой) записи таблицы «Строения на участках».
drop trigger if exists Task7_UpdateTrig;
delimiter $
Create trigger Task7_UpdateTrig before update  on `строения на участках`
for each row
	begin
		update `Участки` set `Количество строений на участке` = `Количество строений на участке` - 1
		where `№ порядковый` = OLD.`№ порядковый`;
        
        update `Участки` set `Количество строений на участке` = `Количество строений на участке` + 1 
		where `№ порядковый` = NEW.`№ порядковый`;
    end; $
delimiter ;
update `строения на участках` set `№ порядковый` = 1001
where `№ порядковый` = 1004 and `№ проекта` = 'Ф105';
select * from `Участки`;
# №8
Create user 'administrator'@'localhost' IDENTIFIED BY 'password1';
Create user 'director'@'localhost' IDENTIFIED BY 'password2';
Create user 'worker'@'localhost' IDENTIFIED BY 'password3';
Create user 'visitor'@'localhost';

# select User,Host from mysql.user;

# 	№9 Назначить пользователю administrator все права доступа, в том числе создания новых пользователей, 
#	их модификации и удаления, кроме создания новых и удаления существующих баз данных, 
#	а также кроме создания таблиц, их модификации и удаления.
Grant grant option,CREATE USER, trigger, Select on `коттеджный посёлок`.* to 'administrator'@'localhost';

# №10 Назначить пользователю director все права доступа ко всем существующим таблицам, 
# кроме создания новых баз данных, таблиц и пользователей, их модификации и удаления.
Grant Select on `коттеджный посёлок`.* to 'director'@'localhost';

# №11 Назначить пользователю worker следующие права доступа:
# 1
Grant  Select,update, insert on `типовые проекты строений`.* to 'worker'@'localhost';
Grant  Select on `типовые проекты строений`.`Стоимость руб.` to 'worker'@'localhost';
# 2
Grant  Select, create on `Участки`.* to 'worker'@'localhost';
Grant  Select, create, update on `Участки`.`Состояние` to 'worker'@'localhost';
# 3
Grant  Select, create, delete, update on `строения на участках`.* to 'worker'@'localhost';

# 12 Создать представление (виртуальную таблицу), содержащую следующие поля: 
# «№ порядковый», «Площадь участка», «Состояние», «№ проекта», «Название проекта», «Общая площадь строения, м2» и «Стоимость, руб.».
Create view Task12 as
Select `Участки`.`№ порядковый`, `Площадь участка`, `Состояние`, `типовые проекты строений`.`№ проекта`, `Название проекта`, `Общая площадь строения`,`Стоимость руб.`
from `Участки` 
inner join `строения на участках` on true
inner join `типовые проекты строений` on true
group by 1,2,3;

# №13 Назначить права доступа visitor только к данному представлению на просмотр.
Grant Select on `коттеджный посёлок`.task12 to 'visitor'@'localhost';

