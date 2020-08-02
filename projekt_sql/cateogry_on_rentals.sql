with

category_film_presence --tabela pośrednia, w której pokazane jest czy dany film jest w jakiejś kategorii czy nie
as (

	with 
	
	possible_combinations --tabela ze wszystkimi możliwymi kombinacjami kategoria+film
		as (
		select category_id, film_id, concat(category_id,'-',film_id) as all_possible from (
			select c.category_id as category_id, f.film_id as film_id from category as c
			cross join film as f
			order by 1, 2) as subquery_1),
		
	actual_combinations --tabela z tylko istniejącymi kombinacjami kategoria+film
		as (
		select category_id, film_id, concat(category_id,'-',film_id) as all_actual from film_category),
		
	total_rentals -- tabela z sumą wszystkich wypożyczeń i przychodów dla poszczególnych filmów
		as (
		select film_id as film_id, count(r.rental_id) as count_rentals, sum(amount) as sum_income from rental as r
		join inventory as i on r.inventory_id = i.inventory_id
		left join payment as p on r.rental_id = p.rental_id
		group by film_id
		order by count(r.rental_id) desc)
		
	select -- konsoliduję tabele possible_combinations, actual_combinations i total_rentals
	pc.category_id,
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
	
select -- tabela pokazująca wpływ danej kategorii na popularność filmu
c.category_id, 
c."name",

		--korelacja kategorii filmu i liczby wypożyczeń
		(select 
		corr(count_rentals, presence) as correlation_rentals
		from (
				select 
				count_rentals, 
				presence 
				from category_film_presence as cfp
				where c.category_id = cfp.category_id) as subquery_2),
				
		--różnica średniej liczby wypożyczeń filmów w których kategorii nie ma i w których kategoria jest
		(select 
		avg(count_rentals) as average_presence
		from (
		
				--średnia kiedy kategoria jest
				select 
				count_rentals, 
				presence 
				from category_film_presence as cfp
				where c.category_id = cfp.category_id
				and presence = 1) as subquery_3) -  --znak różnicy
		(select 
		avg(count_rentals) as average_absence
		from (
		
				--średnia kiedy kategorii nie ma
				select 
				count_rentals, 
				presence 
				from category_film_presence as cfp
				where c.category_id = cfp.category_id
				and presence = 0) as subquery_4) as diff_avg_rentals
		
from category as c
order by correlation_rentals desc

