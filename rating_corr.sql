create table rat as(
select distinct rating from film)

with

rating_film_presence --tabela pośrednia, w której pokazane jest czy dany aktor występuje w jakimś filmie czy nie
as (

	with 
	
	possible_combinations --tabela ze wszystkimi możliwymi kombinacjami aktor+film
		as (
		
		with
		
		rating_table as (
		
			select distinct rating from film)
			
			select rating, film_id, concat(rating,'-',film_id) as all_possible from (
				select rt.rating as rating, f.film_id as film_id from film as f
				cross join rating_table as rt
				order by 1, 2) as subquery_1),
			
		actual_combinations --tabela z tylko istniejącymi kombinacjami aktor+film
			as (
			select rating, film_id, concat(rating,'-',film_id) as all_actual from film),
			
		total_rentals -- tabela z sumą wszystkich wypożyczeń i przychodów dla poszczególnych filmów
			as (
			select film_id as film_id, count(r.rental_id) as count_rentals, sum(amount) as sum_income from rental as r
			join inventory as i on r.inventory_id = i.inventory_id
			left join payment as p on r.rental_id = p.rental_id
			group by film_id
			order by count(r.rental_id) desc)
			
		select -- konsoliduję tabele possible_combinations, actual_combinations i total_rentals
		pc.rating,
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
	rat.rating,
	
			--korelacja obecności aktora w filmie i liczby wypożyczeń
			(select 
			corr(count_rentals, presence) as correlation_rentals
			from (
					select 
					count_rentals, 
					presence 
					from rating_film_presence as rfp
					where rat.rating = rfp.rating) as subquery_2),
					
			--różnica średniej liczby wypożyczeń filmów w których akotra nie ma i w których aktor jest
			(select 
			avg(count_rentals) as average_presence
			from (
			
					--średnia kiedy aktor jest
					select 
					count_rentals, 
					presence 
					from rating_film_presence as rfp
					where rat.rating = rfp.rating
					and presence = 1) as subquery_3) -  --znak różnicy
			(select 
			avg(count_rentals) as average_absence
			from (
			
					--średnia kiedy aktora nie ma
					select 
					count_rentals, 
					presence 
					from rating_film_presence as rfp
					where rat.rating = rfp.rating
					and presence = 0) as subquery_4) as diff_avg_rentals,
			
			--korelacja obecności aktora w filmie i sumy przychodów z filmu
			(select 
			corr(sum_income, presence) as correlation_income
			from (
					select 
					sum_income, 
					presence 
					from rating_film_presence as rfp
					where rat.rating = rfp.rating) as subquery_5),
					
			--różnica średniej liczby wypożyczeń filmów w których akotra nie ma i w których aktor jest
			(select 
			avg(sum_income) as average_presence
			from (
			
					--średnia kiedy aktor jest
					select 
					sum_income, 
					presence 
					from rating_film_presence as rfp
					where rat.rating = rfp.rating
					and presence = 1) as subquery_6) -  --znak różnicy
			(select 
			avg(sum_income) as average_absence
			from (
			
					--średnia kiedy aktora nie ma
					select 
					sum_income, 
					presence 
					from rating_film_presence as rfp
					where rat.rating = rfp.rating
					and presence = 0) as subquery_7) as diff_avg_income
from rat
order by correlation_income desc

