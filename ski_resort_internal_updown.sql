if not exists(select * from sys.databases where name='skierdb')
    create database skierdb
go

use skierdb
GO

-- DOWN
drop trigger if exists t_ticket_datetimes
if exists(select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    where CONSTRAINT_NAME='fk_ticket_skier_id' )
    alter table tickets drop constraint fk_ticket_skier_id
if exists(select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    where CONSTRAINT_NAME='fk_ticket_ticket_type_id' )
    alter table tickets drop constraint fk_ticket_ticket_type_id
if exists(select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    where CONSTRAINT_NAME='fk_rental_skier_id' )
    alter table rentals drop constraint fk_rental_skier_id
drop table if exists skiers
drop table if exists ticket_types
drop table if exists tickets
drop table if exists rentals
go

-- UP Metadata
create table skiers (
    skier_id int identity not null
    , skier_firstname varchar(50) not null
    , skier_lastname varchar(50) not null
    , skier_email varchar(100) not null
    , skier_date_of_birth date null
    , constraint pk_skier_id primary key(skier_id)
    , constraint u_skier_email unique(skier_email)
    , constraint ch_skier_date_of_birth_gt_1900 check(skier_date_of_birth > '1900-01-01')
)

create table ticket_types (
    ticket_type_id int identity not null
    , ticket_type_name varchar(50) not null
    , ticket_price money not null
    , constraint pk_ticket_type_id primary key(ticket_type_id)
)

create table tickets (
    ticket_id int identity not null
    , ticket_skier_id int not null
    , ticket_ticket_type_id int not null
    , ticket_datetime_purchased datetime not NULL default getdate()
    , ticket_datetime_begin datetime not NULL
    , ticket_datetime_end datetime not NULL
    , constraint pk_ticket_id primary key(ticket_id)
    , constraint fk_ticket_skier_id foreign key(ticket_skier_id) references skiers(skier_id)
    , constraint fk_ticket_ticket_type_id foreign key(ticket_ticket_type_id) references ticket_types(ticket_type_id)
)

go
create trigger t_ticket_datetimes
    on tickets instead of insert as
    BEGIN
        declare @begin_date datetime = (select ticket_datetime_begin from inserted)
        declare @ticket_type varchar(50) = (select ticket_type_name from inserted join ticket_types on ticket_ticket_type_id=ticket_type_id)        
        declare @begin_datetime_est datetime =
            case when @ticket_type = 'PM' then concat(cast(@begin_date as date), ' 12:30:00')
                else concat(cast(@begin_date as date), ' 08:30:00')
            end
        declare @begin_datetime_utc datetime = dateadd(hour, 5, @begin_datetime_est)
        declare @end_datetime_est datetime = 
            case
                when @ticket_type = 'AM' then concat(cast(@begin_date as date), ' 12:00:00')
                when @ticket_type = 'PM' or @ticket_type = 'One Day' then concat(cast(@begin_date as date), ' 16:00:00')
                when @ticket_type = 'Two Day' then concat(dateadd(day, 1, cast(@begin_date as date)), ' 16:00:00')
                when @ticket_type = 'Three Day' then concat(dateadd(day, 2, cast(@begin_date as date)), ' 16:00:00')
                when @ticket_type = 'Season' and month(@begin_date) > 4 then concat(year(@begin_date)+1, '-04-10 16:00:00')
                when @ticket_type = 'Season' and month(@begin_date) < 4 then concat(year(@begin_date), '-04-10 16:00:00')
            end
        declare @end_datetime_utc datetime = dateadd(hour, 5, @end_datetime_est)
        insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_purchased, ticket_datetime_begin, ticket_datetime_end)
            values (
                    (select ticket_skier_id from inserted), 
                    (select ticket_ticket_type_id from inserted), 
                    (select ticket_datetime_purchased from inserted), 
                    @begin_datetime_utc, 
                    @end_datetime_utc
                    )
    END
go

create table rentals (
    rental_id int identity not null
    , rental_skier_id int not NULL
    , rental_datetime_purchased datetime not null default getdate()
    , rental_datetime_taken_out datetime NULL
    , rental_datetime_returned datetime null
    , constraint pk_rental_id primary key(rental_id)
    , constraint fk_rental_skier_id foreign key(rental_skier_id) references skiers(skier_id)
)

go
-- UP Data

-- Insert 50 skiers
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Johannes', 'Botha', 'jbotha0@lycos.com', '8/17/1987');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Tami', 'Youles', 'tyoules1@nymag.com', '4/17/1927');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Noami', 'Scotts', 'nscotts2@thetimes.co.uk', '7/18/1935');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Godfree', 'Rumens', 'grumens3@google.com.au', '9/29/1998');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Sharai', 'Tailour', 'stailour4@acquirethisname.com', '4/22/1960');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Blair', 'Oddey', 'boddey5@mit.edu', '8/8/2010');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Yorker', 'Hengoed', 'yhengoed6@naver.com', '5/27/1951');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Douglas', 'Laurentin', 'dlaurentin7@ezinearticles.com', '2/8/1949');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Cece', 'Courtes', 'ccourtes8@meetup.com', '6/7/1929');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Cody', 'Kobsch', 'ckobsch9@narod.ru', '7/27/2004');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Bernardine', 'Oakton', 'boaktona@miibeian.gov.cn', '12/27/1955');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Simon', 'Chedgey', 'schedgeyb@sakura.ne.jp', '12/26/2010');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Tomlin', 'Prestige', 'tprestigec@merriam-webster.com', '1/26/1963');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Mercy', 'Crowter', 'mcrowterd@spotify.com', '12/27/1981');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Rochell', 'Boyton', 'rboytone@acquirethisname.com', '5/11/1952');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Brena', 'Oakland', 'boaklandf@tumblr.com', '11/5/2008');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Elroy', 'Salmons', 'esalmonsg@huffingtonpost.com', '11/7/1990');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Geralda', 'Lampel', 'glampelh@unesco.org', '9/5/1956');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Shelbi', 'Grinter', 'sgrinteri@kickstarter.com', '9/30/2004');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Sonja', 'Neward', 'snewardj@aboutads.info', '6/3/2009');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Moyna', 'Ryal', 'mryalk@economist.com', '9/24/1962');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Max', 'Troake', 'mtroakel@biblegateway.com', '9/14/1946');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Doretta', 'Shivell', 'dshivellm@bloglovin.com', '8/24/1951');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Minny', 'Coltan', 'mcoltann@eepurl.com', '12/21/1992');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Bab', 'Rivett', 'brivetto@google.com.hk', '9/6/1939');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Nicky', 'Allender', 'nallenderp@phoca.cz', '10/31/1967');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Latia', 'McDaid', 'lmcdaidq@pinterest.com', '7/15/2018');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Elva', 'Lannen', 'elannenr@foxnews.com', '12/10/1942');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Bunnie', 'Covelle', 'bcovelles@usgs.gov', '9/1/2008');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Granthem', 'Affron', 'gaffront@unblog.fr', '12/16/1960');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Dinny', 'Nowaczyk', 'dnowaczyku@java.com', '12/31/1982');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Ambrosio', 'Pitcaithly', 'apitcaithlyv@nba.com', '4/25/1969');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Yetta', 'Reasce', 'yreascew@e-recht24.de', '4/7/1992');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Fred', 'Pringle', 'fpringlex@tamu.edu', '5/18/1980');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Belia', 'Gostage', 'bgostagey@webmd.com', '3/21/1948');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Desiri', 'Davern', 'ddavernz@com.com', '9/13/2020');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Patsy', 'Stobie', 'pstobie10@fotki.com', '7/21/1995');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Retha', 'Thaxton', 'rthaxton11@icq.com', '4/3/2022');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Rebbecca', 'Wooles', 'rwooles12@newyorker.com', '8/17/2001');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Jsandye', 'Cham', 'jcham13@hc360.com', '9/3/1948');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Thom', 'Carriage', 'tcarriage14@networksolutions.com', '11/17/1944');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Hoebart', 'Bloan', 'hbloan15@cnbc.com', '5/16/1959');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Zedekiah', 'Iwanczyk', 'ziwanczyk16@canalblog.com', '6/21/1954');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Gustave', 'Redshaw', 'gredshaw17@unblog.fr', '5/31/1938');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Fidel', 'McMorran', 'fmcmorran18@unc.edu', '8/25/1943');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Teodoor', 'Budge', 'tbudge19@yellowpages.com', '5/7/1984');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Morgana', 'Dysart', 'mdysart1a@kickstarter.com', '6/15/1966');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Dulcia', 'Pittwood', 'dpittwood1b@economist.com', '12/27/1970');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Mozes', 'Patron', 'mpatron1c@bing.com', '7/13/1997');
insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) values ('Olivette', 'Berka', 'oberka1d@forbes.com', '12/18/1962');

-- Insert Ticket Types
insert into ticket_types (ticket_type_name, ticket_price) values 
    ('AM', 50)
    , ('PM', 50)
    , ('One Day', 70)
    , ('Two Day', 130)
    , ('Three Day', 190)
    , ('Season', 500)



-- Insert 70 tickets
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (50, 2, '2022-04-07');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (43, 4, '2022-05-17');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (1, 1, '2022-08-21');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (38, 6, '2022-08-25');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (48, 1, '2022-09-03');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (10, 3, '2023-01-23');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (8, 5, '2022-12-01');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (1, 1, '2022-07-02');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (37, 2, '2022-04-14');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (47, 1, '2022-11-04');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (21, 5, '2022-09-03');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (30, 5, '2022-08-30');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (27, 1, '2023-02-26');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (16, 2, '2022-10-13');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (38, 5, '2023-02-19');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (42, 4, '2023-03-23');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (17, 3, '2022-12-26');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (41, 2, '2022-08-18');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (47, 4, '2022-11-08');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (5, 2, '2022-05-21');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (20, 5, '2023-03-04');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (38, 5, '2022-05-27');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (16, 2, '2022-10-04');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (24, 2, '2022-08-30');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (47, 5, '2022-12-04');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (47, 2, '2022-10-18');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (8, 3, '2022-10-29');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (31, 2, '2022-07-07');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (19, 3, '2022-10-05');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (47, 6, '2022-06-29');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (34, 6, '2023-02-23');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (46, 2, '2023-01-16');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (7, 6, '2022-12-05');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (16, 2, '2022-04-11');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (22, 3, '2022-03-23');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (19, 2, '2022-10-02');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (4, 1, '2022-04-13');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (35, 3, '2023-03-09');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (47, 2, '2022-08-18');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (28, 4, '2023-01-15');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (37, 5, '2022-06-02');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (18, 2, '2022-11-03');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (3, 6, '2022-03-18');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (5, 6, '2022-12-05');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (45, 3, '2022-06-25');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (3, 4, '2022-06-29');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (18, 3, '2022-10-02');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (15, 6, '2023-03-22');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (23, 3, '2022-07-26');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (14, 2, '2022-03-18');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (28, 4, '2022-11-07');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (33, 3, '2022-10-20');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (18, 2, '2022-05-18');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (12, 1, '2022-11-06');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (24, 2, '2023-01-29');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (33, 6, '2022-07-23');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (1, 2, '2022-04-02');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (32, 2, '2022-11-09');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (6, 2, '2023-02-22');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (19, 6, '2022-05-23');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (48, 1, '2022-11-05');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (38, 2, '2022-11-04');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (3, 2, '2022-12-16');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (30, 4, '2022-12-31');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (37, 6, '2022-08-01');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (18, 2, '2022-12-31');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (18, 4, '2022-12-15');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (8, 3, '2022-10-17');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (35, 1, '2022-10-14');
insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) values (42, 2, '2022-08-03');

-- Insert 60 Rentals
insert into rentals (rental_skier_id) values (24);
insert into rentals (rental_skier_id) values (31);
insert into rentals (rental_skier_id) values (4);
insert into rentals (rental_skier_id) values (24);
insert into rentals (rental_skier_id) values (16);
insert into rentals (rental_skier_id) values (2);
insert into rentals (rental_skier_id) values (11);
insert into rentals (rental_skier_id) values (28);
insert into rentals (rental_skier_id) values (35);
insert into rentals (rental_skier_id) values (40);
insert into rentals (rental_skier_id) values (22);
insert into rentals (rental_skier_id) values (25);
insert into rentals (rental_skier_id) values (7);
insert into rentals (rental_skier_id) values (30);
insert into rentals (rental_skier_id) values (33);
insert into rentals (rental_skier_id) values (37);
insert into rentals (rental_skier_id) values (42);
insert into rentals (rental_skier_id) values (23);
insert into rentals (rental_skier_id) values (24);
insert into rentals (rental_skier_id) values (4);
insert into rentals (rental_skier_id) values (20);
insert into rentals (rental_skier_id) values (10);
insert into rentals (rental_skier_id) values (20);
insert into rentals (rental_skier_id) values (39);
insert into rentals (rental_skier_id) values (2);
insert into rentals (rental_skier_id) values (7);
insert into rentals (rental_skier_id) values (17);
insert into rentals (rental_skier_id) values (27);
insert into rentals (rental_skier_id) values (1);
insert into rentals (rental_skier_id) values (1);
insert into rentals (rental_skier_id) values (1);
insert into rentals (rental_skier_id) values (37);
insert into rentals (rental_skier_id) values (22);
insert into rentals (rental_skier_id) values (17);
insert into rentals (rental_skier_id) values (5);
insert into rentals (rental_skier_id) values (35);
insert into rentals (rental_skier_id) values (28);
insert into rentals (rental_skier_id) values (20);
insert into rentals (rental_skier_id) values (37);
insert into rentals (rental_skier_id) values (12);
insert into rentals (rental_skier_id) values (24);
insert into rentals (rental_skier_id) values (38);
insert into rentals (rental_skier_id) values (11);
insert into rentals (rental_skier_id) values (45);
insert into rentals (rental_skier_id) values (35);
insert into rentals (rental_skier_id) values (28);
insert into rentals (rental_skier_id) values (37);
insert into rentals (rental_skier_id) values (39);
insert into rentals (rental_skier_id) values (24);
insert into rentals (rental_skier_id) values (19);
insert into rentals (rental_skier_id) values (33);
insert into rentals (rental_skier_id) values (49);
insert into rentals (rental_skier_id) values (4);
insert into rentals (rental_skier_id) values (35);
insert into rentals (rental_skier_id) values (20);
insert into rentals (rental_skier_id) values (44);
insert into rentals (rental_skier_id) values (22);
insert into rentals (rental_skier_id) values (27);
insert into rentals (rental_skier_id) values (31);
insert into rentals (rental_skier_id) values (11);


go
-- Verify


select TOP 5 * from skiers
select * from ticket_types
select TOP 5 * from tickets
select TOP 5 * from rentals