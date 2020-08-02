with

actor_film_presence --tabela pośrednia, w której pokazane jest czy dany aktor występuje w jakimś filmie czy nie
as (

	with 
	
	possible_combinations --tabela ze wszystkimi możliwymi kombinacjami aktor+film
		as (
		select actor_id, film_id, concat(actor_id,'-',film_id) as all_possible from (
			select a.actor_id as actor_id, f.film_id as film_id from actor as a
			cross join film as f
			order by 1, 2) as subquery_1),
		
	actual_combinations --tabela z tylko istniejącymi kombinacjami aktor+film
		as (
		select actor_id, film_id, concat(actor_id,'-',film_id) as all_actual from film_actor),
		
	total_rentals -- tabela z sumą wszystkich wypożyczeń i przychodów dla poszczególnych filmów
		as (
		select film_id as film_id, count(r.rental_id) as count_rentals, sum(amount) as sum_income from rental as r
		join inventory as i on r.inventory_id = i.inventory_id
		left join payment as p on r.rental_id = p.rental_id
		group by film_id
		order by count(r.rental_id) desc)
		
	select -- konsoliduję tabele possible_combinations, actual_combinations i total_rentals
	pc.actor_id,
	pc.film_id,
	tr.count_rentals,
	tr.sum_income,
	pc.all_possible,
	ac.all_actual,
	case when ac.all_actual is null then 0 else 1 end as presence
	from possible_combinations as pc
	join total_rentals as tr on pc.film_id = tr.film_id
	left join actual_combinations as ac on pc.all_possible = ac.all_actual
	order by 1, 2)
	
select -- tabela pokazująca wpływ danego aktora na popularność filmu
a.actor_id,
concat(first_name,' ',last_name),

		--korelacja obecności aktora w filmie i liczby wypożyczeń
		(select 
		corr(count_rentals, presence) as correlation_rentals
		from (
				select 
				count_rentals, 
				presence 
				from actor_film_presence as afp
				where a.actor_id = afp.actor_id) as subquery_2),
				
		--różnica średniej liczby wypożyczeń filmów w których akotra nie ma i w których aktor jest
		(select 
		avg(count_rentals) as average_presence
		from (
		
				--średnia kiedy aktor jest
				select 
				count_rentals, 
				presence 
				from actor_film_presence as afp
				where a.actor_id = afp.actor_id
				and presence = 1) as subquery_3) -  --znak różnicy
		(select 
		avg(count_rentals) as average_absence
		from (
		
				--średnia kiedy aktora nie ma
				select 
				count_rentals, 
				presence 
				from actor_film_presence as afp
				where a.actor_id = afp.actor_id
				and presence = 0) as subquery_4) as diff_avg_rentals
		
from actor as a
order by correlation_rentals desc

