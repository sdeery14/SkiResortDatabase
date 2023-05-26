use skierdb
GO

-- DOWN
drop view if exists v_attendant_tickets
drop view if exists v_attendant_rentals
drop procedure if exists p_sign_up
drop procedure if exists p_sell_ticket
drop procedure if exists p_sell_rental
drop procedure if exists p_activate_rental
drop procedure if exists p_deactivate_rental
drop view if exists v_lift
GO


-- UP Metadata


-- MAIN OFFICE

-- View to see current and upcoming tickets and rentals. For the skier app and main office app.
create view v_attendant_tickets AS
    select s.*, t.*, tt.* from skiers s
        join tickets t on s.skier_id = t.ticket_skier_id 
        join ticket_types tt on t.ticket_ticket_type_id = tt.ticket_type_id
go

select * from v_attendant_tickets
go

create view v_attendant_rentals AS
    select s.*, r.* from skiers s
        join rentals r on s.skier_id = r.rental_skier_id
go

select * from v_attendant_rentals
go

-- Stored procedure to create a skier account, for skier app and main office app.
create procedure p_sign_up (
    @skier_firstname varchar(50)
    , @skier_lastname varchar(50)
    , @skier_email varchar(100)
    , @skier_date_of_birth date
) as BEGIN
    begin transaction
    begin try
        if exists(select skier_email from skiers where skier_email=@skier_email) throw 50001, 'Skier email already exists', 1
        insert into skiers (skier_firstname, skier_lastname, skier_email, skier_date_of_birth) 
            values (@skier_firstname, @skier_lastname, @skier_email, @skier_date_of_birth)
        if @@ROWCOUNT <> 1 throw 50002, 'Could not create skier account',1 
        commit
        return @@identity
    end TRY
    begin CATCH
        ROLLBACK
        ;
        throw
    end catch
end
go

delete from skiers where skier_email='istenmark@gmail.com'
go
exec p_sign_up @skier_firstname='Ingemar', @skier_lastname='Stenmark', @skier_email='istenmark@gmail.com', @skier_date_of_birth='1956-03-18'
go
select * from skiers where skier_email='istenmark@gmail.com'
go


-- Sell a lift ticket procedure
create procedure p_sell_ticket (
    @ticket_skier_id INT
    , @ticket_ticket_type_id INT
    , @ticket_datetime_begin datetime
) as BEGIN
    begin TRANSACTION
    begin try
        insert into tickets (ticket_skier_id, ticket_ticket_type_id, ticket_datetime_begin) 
            values (@ticket_skier_id, @ticket_ticket_type_id, @ticket_datetime_begin)
        if @@ROWCOUNT <> 1 throw 50003, 'Could not complete ticket purchase',1 
        commit
        return @@identity
    end TRY
    begin catch
        ROLLBACK
        ;
        throw
    end catch
end
go
delete from tickets where ticket_datetime_begin='2023-03-25 12:30:00'
go
exec p_sell_ticket @ticket_skier_id=1, @ticket_ticket_type_id=2, @ticket_datetime_begin='2023-03-25'
go
select * from tickets where ticket_datetime_begin='2023-03-25 12:30:00'
go

-- Sell a rental stored procedure
create procedure p_sell_rental (
    @rental_skier_id INT
) as BEGIN
    begin TRANSACTION
    begin try
        insert into rentals (rental_skier_id) values (@rental_skier_id)
        if @@ROWCOUNT <> 1 throw 50004, 'Could not complete rental purchase',1 
        COMMIT
    end TRY
    begin catch
        ROLLBACK
        ;
        THROW
    end catch
END
go
delete from rentals where rental_skier_id=2
go
exec p_sell_rental @rental_skier_id=2
go
select * from rentals where rental_skier_id=2
go



-- RENTAL SHOP

-- Procedure to distribute and activate rental
create procedure p_activate_rental (
    @ticket_id int
) as BEGIN
    begin TRANSACTION
    begin try
        update top(1) rentals
            set rental_datetime_taken_out=getdate()
        from rentals r
            join skiers s on r.rental_skier_id=s.skier_id
            join tickets t on t.ticket_skier_id=s.skier_id
        where ticket_id=@ticket_id and rental_datetime_taken_out is null
        if @@ROWCOUNT <> 1 throw 50005, 'Could not activate rental',1 
        commit
    end TRY
    begin catch
        ROLLBACK
        ;
        THROW
    end catch
END
go
update rentals set rental_datetime_taken_out=null where rental_skier_id=1
GO
exec p_activate_rental @ticket_id=3
go
select distinct r.* from rentals r
    join skiers s on r.rental_skier_id=s.skier_id
    join tickets t on s.skier_id = t.ticket_skier_id 
where rental_skier_id=1
go

-- Procedure to collect and deactivate rental
create procedure p_deactivate_rental (
    @ticket_id int
) as BEGIN
    begin TRANSACTION
    begin try
        update top(1) rentals
            set rental_datetime_returned=getdate()
        from rentals r
            join skiers s on r.rental_skier_id=s.skier_id
            join tickets t on t.ticket_skier_id=s.skier_id
        where ticket_id=@ticket_id and rental_datetime_returned is null
        if @@ROWCOUNT <> 1 throw 50006, 'Could not deactivate rental',1
        commit
    end TRY
    begin CATCH
        ROLLBACK
        ;
        THROW
    end catch
END
go
update rentals set rental_datetime_returned=null where rental_skier_id=1
GO
exec p_deactivate_rental @ticket_id=3
go
select distinct r.* from rentals r
    join skiers s on r.rental_skier_id=s.skier_id
    join tickets t on s.skier_id = t.ticket_skier_id 
where rental_skier_id=1
go



-- LIFT GATES

-- View to validate ticket and open gate
create view v_lift AS
    select * from tickets where ticket_datetime_begin <= getdate() and ticket_datetime_end >= getdate()
go
select * from v_lift