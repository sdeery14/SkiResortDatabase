/*
This implementation is for when the Griffins visit the ski resort
*/

use skierdb
GO

/*
Peter Griffin decides to take a family out for a ski day to our resort, which he has never been to before. 
He calls into the main office and purchases tickets and rentals from the main office attendant.
*/

-- First the main attendant sets up a skier account for Peter
delete from skiers where skier_email='peter@familyguy.com'
declare @skier_id int
exec @skier_id = p_sign_up @skier_firstname='Peter', @skier_lastname='Griffin', @skier_email='peter@familyguy.com', @skier_date_of_birth='1966-09-22'

select * from skiers where skier_email='peter@familyguy.com'

-- Next, the main attendant sells 6 One Day tickets and 6 rentals since none of the Griffins own skis.
declare @ticket_id1 int
declare @ticket_id2 int
declare @ticket_id3 int
declare @ticket_id4 int
declare @ticket_id5 int
declare @ticket_id6 int
exec @ticket_id1 = p_sell_ticket @ticket_skier_id=@skier_id, @ticket_ticket_type_id=3, @ticket_datetime_begin='2023-03-27'
exec @ticket_id2 = p_sell_ticket @ticket_skier_id=@skier_id, @ticket_ticket_type_id=3, @ticket_datetime_begin='2023-03-27'
exec @ticket_id3 = p_sell_ticket @ticket_skier_id=@skier_id, @ticket_ticket_type_id=3, @ticket_datetime_begin='2023-03-27'
exec @ticket_id4 = p_sell_ticket @ticket_skier_id=@skier_id, @ticket_ticket_type_id=3, @ticket_datetime_begin='2023-03-27'
exec @ticket_id5 = p_sell_ticket @ticket_skier_id=@skier_id, @ticket_ticket_type_id=3, @ticket_datetime_begin='2023-03-27'
exec @ticket_id6 = p_sell_ticket @ticket_skier_id=@skier_id, @ticket_ticket_type_id=3, @ticket_datetime_begin='2023-03-27'
exec p_sell_rental @rental_skier_id=@skier_id
exec p_sell_rental @rental_skier_id=@skier_id
exec p_sell_rental @rental_skier_id=@skier_id
exec p_sell_rental @rental_skier_id=@skier_id
exec p_sell_rental @rental_skier_id=@skier_id
exec p_sell_rental @rental_skier_id=@skier_id

-- The Griffins drive to the resort and they show up to the main office to collect their lift tickets. 
-- The main office attendant is able to look up the skier's tickets and print out the correct ones by the begin/end dates.
select * from v_attendant_tickets where skier_email='peter@familyguy.com'

-- The Griffins go from the main office over to the rental shop and scan their tickets to receive and activate their rentals
select * from rentals where rental_skier_id=@skier_id

exec p_activate_rental @ticket_id=@ticket_id1
exec p_activate_rental @ticket_id=@ticket_id2
exec p_activate_rental @ticket_id=@ticket_id3
exec p_activate_rental @ticket_id=@ticket_id4
exec p_activate_rental @ticket_id=@ticket_id5
exec p_activate_rental @ticket_id=@ticket_id6

select * from rentals where rental_skier_id=@skier_id

-- Stewie is evil so he tries to take a second rental so he can sell it on the black market.
-- The rental shop attendant sees that the rental is not valid and directs Stewie to the main office to purchase a rental.
-- exec p_activate_rental @ticket_id=@ticket_id6

-- The Griffins go up the lift
select * from v_lift where ticket_id=@ticket_id1
select * from v_lift where ticket_id=@ticket_id2
select * from v_lift where ticket_id=@ticket_id3
select * from v_lift where ticket_id=@ticket_id4
select * from v_lift where ticket_id=@ticket_id5
select * from v_lift where ticket_id=@ticket_id6

-- The Griffins return their rental equipment at the rental shop
-- Stewie is still evil so he does not return his rental equipment
select * from rentals where rental_skier_id=@skier_id

exec p_deactivate_rental @ticket_id=@ticket_id1
exec p_deactivate_rental @ticket_id=@ticket_id2
exec p_deactivate_rental @ticket_id=@ticket_id3
exec p_deactivate_rental @ticket_id=@ticket_id4
exec p_deactivate_rental @ticket_id=@ticket_id5

select * from rentals where rental_skier_id=@skier_id

-- The main office auto attendent checks if all the rentals were returned
select * from v_attendant_rentals where rental_datetime_taken_out is not null and rental_datetime_returned is null