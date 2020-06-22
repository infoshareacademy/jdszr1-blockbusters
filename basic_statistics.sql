-- (total rentals, total income, average unitary income) per film

with
tabela_2
as (
	with
	tabela_1
	as (
		select film_id as film_id, count(r.rental_id) as count_rentals, sum(amount) as sum_income from rental as r
		join inventory as i on r.inventory_id = i.inventory_id
		left join payment as p on r.rental_id = p.rental_id
		group by film_id
		order by sum(amount) desc)
	select
	film_id,
	count_rentals, 
	sum_income, 
	sum_income/count_rentals as income_rate
	from tabela_1)
select
film_id,
count_rentals, 
sum_income,
income_rate,
rank() over (order by count_rentals desc) as rank_rentals, 
rank() over (order by sum_income desc) as rank_income,
rank() over (order by income_rate desc) as rank_rate
from tabela_2
order by sum_income desc

-- (total rentals, total income, average unitary income) per actor

with
tabela_2
as (
	with
	tabela_1
	as (
		select actor_id, sum(total_rentals) as total_rentals, sum(sum_income) as sum_income from (
				select film_id as film_id, count(r.rental_id) as total_rentals, sum(amount) as sum_income from rental as r
				join inventory as i on r.inventory_id = i.inventory_id
				left join payment as p on r.rental_id = p.rental_id
				group by film_id
				order by count(r.rental_id) desc) as p1
		join film_actor as fa on p1.film_id = fa.film_id
		group by actor_id
		order by sum(sum_income) desc)
	select
	actor_id, 
	total_rentals, 
	sum_income,
	sum_income/total_rentals as income_rate
	from tabela_1)
select 
actor_id, 
total_rentals, 
sum_income,
income_rate,
rank() over (order by total_rentals desc) as rank_rentals, 
rank() over (order by sum_income desc) as rank_income,
rank() over (order by income_rate desc) as rank_rate
from tabela_2
order by sum_income desc
	

-- (total rentals, total income, average unitary income) per category

with
tabela_2
as (
	with
	tabela_1
	as (
		select category_id, sum(total_rentals) as total_rentals, sum(sum_income) as sum_income from (
				select film_id as film_id, count(r.rental_id) as total_rentals, sum(amount) as sum_income from rental as r
				join inventory as i on r.inventory_id = i.inventory_id
				left join payment as p on r.rental_id = p.rental_id
				group by film_id
				order by count(r.rental_id) desc) as p1
		join film_category as fc on p1.film_id = fc.film_id
		group by category_id
		order by sum(sum_income) desc)
	select
	category_id, 
	total_rentals, 
	sum_income,
	sum_income/total_rentals as income_rate
	from tabela_1)
select 
category_id, 
total_rentals, 
sum_income,
income_rate,
rank() over (order by total_rentals desc) as rank_rentals, 
rank() over (order by sum_income desc) as rank_income,
rank() over (order by income_rate desc) as rank_rate
from tabela_2
order by sum_income desc	
	
-- (total rentals, total income, average unitary income) per rating

with
tabela_2
as (
	with
	tabela_1
	as (
		select rating, sum(total_rentals) as total_rentals, sum(sum_income) as sum_income from (
				select f.rating as rating, count(r.rental_id) as total_rentals, sum(amount) as sum_income from rental as r
				join inventory as i on r.inventory_id = i.inventory_id
				left join payment as p on r.rental_id = p.rental_id
				join film as f on i.film_id = f.film_id
				group by rating
				order by count(r.rental_id) desc) as p1
		group by rating
		order by sum(sum_income) desc)
	select
	rating, 
	total_rentals, 
	sum_income,
	sum_income/total_rentals as income_rate
	from tabela_1)
select 
rating, 
total_rentals, 
sum_income,
income_rate,
rank() over (order by total_rentals desc) as rank_rentals, 
rank() over (order by sum_income desc) as rank_income,
rank() over (order by income_rate desc) as rank_rate
from tabela_2
order by sum_income desc

-- (total rentals, total income, average unitary income) per price

with
tabela_2
as (
	with
	tabela_1
	as (
		select rental_rate, sum(total_rentals) as total_rentals, sum(sum_income) as sum_income from (
				select f.rental_rate as rental_rate, count(r.rental_id) as total_rentals, sum(amount) as sum_income from rental as r
				join inventory as i on r.inventory_id = i.inventory_id
				left join payment as p on r.rental_id = p.rental_id
				join film as f on i.film_id = f.film_id
				group by rental_rate
				order by count(r.rental_id) desc) as p1
		group by rental_rate
		order by sum(sum_income) desc)
	select
	rental_rate, 
	total_rentals, 
	sum_income,
	sum_income/total_rentals as income_rate
	from tabela_1)
select 
rental_rate, 
total_rentals, 
sum_income,
income_rate,
rank() over (order by total_rentals desc) as rank_rentals, 
rank() over (order by sum_income desc) as rank_income,
rank() over (order by income_rate desc) as rank_rate
from tabela_2
order by sum_income desc






