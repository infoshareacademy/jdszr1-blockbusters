with x as( select i.film_id as film_id, count(r.rental_id) as count_rentals, sum(amount) as sum_income, f.length, f.rental_rate 
	from rental as r
		join inventory as i on r.inventory_id = i.inventory_id
		left join payment as p on r.rental_id = p.rental_id
		join film as f on f.film_id=i.film_id 
		group by i.film_id, f.length ,f.rental_rate
		order by count(r.rental_id) desc)
select 
corr(length,count_rentals) as dlugosc_wypozyczenia,
corr(length,sum_income) as dlugosc_dochod,
corr(rental_rate,count_rentals) as cena_wypozyczenia,
corr(rental_rate, sum_income) as cena_dochod
from x

		