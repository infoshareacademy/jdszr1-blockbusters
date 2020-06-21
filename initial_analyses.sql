--Czy aktor ma wpływ na popularność filmu i dochód z wypożyczeń?  Czy zmieniało się to na przestrzeni lat ?

select first_name,last_name from actor;

select concat(upper(first_name), ' ', upper(last_name)) as "Actor Name" from actor;

--największy przychód (aktorzy)
SELECT actor_id, a.first_name, a.last_name, 
       sum(p.amount)
FROM actor a
JOIN film_actor fa USING (actor_id)
JOIN inventory i USING (film_id)
JOIN rental r USING (inventory_id)
JOIN payment p USING (rental_id)
GROUP BY actor_id, a.first_name, a.last_name
ORDER BY 4 desc

--największy przychód (filmy)
SELECT film_id, f.title, sum(p.amount)
FROM film f
JOIN inventory i USING (film_id)
JOIN rental r USING (inventory_id)
JOIN payment p USING (rental_id)
GROUP BY film_id, f.title
ORDER BY 3 desc

--największy przychód (kategoria)
SELECT category_id, c.name, sum(p.amount)
FROM category c
JOIN film_category fc USING (category_id)
JOIN inventory i USING (film_id)
JOIN rental r USING (inventory_id)
JOIN payment p USING (rental_id)
GROUP BY category_id, c.name
ORDER BY 3 desc

select count(*) from film_actor fa
where actor_id = 107;
select count(*) from film_actor fa
where actor_id = 181;
select count(*) from film_actor fa
where actor_id = 198;

select count(distinct actor_id) from film_actor fa;

