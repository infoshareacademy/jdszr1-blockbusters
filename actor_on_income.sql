/* kod generujący tabelę, w której pokazana jest: (1) korelacja obecności danego aktora w filmie i liczby wypożyczeń filmów
                                                  (2) różnia średniej liczby wypożyczeń filmów, w których dany aktor jest i
                                                      średniej liczby wypożyczeń filmów, w których go nie ma */
  
  with actor_film_presence as --tabela pośrednia pokazująca: (1) czy dany aktor występuje w filmie (presence)
                                                          -- (2) ile dany film miał łącznie wypożyczeń (count_rentals)
                                                          -- (3) jaki był łączny przychód wygenerowany przez dany film (sum_income)
  
       (with possible_combinations as --tabela pośrednia pokazująca wszystkie możliwe kombinacje aktorów i filmów
             (select actor_id 
	               , film_id
	               , concat(actor_id,'-',film_id) as all_possible
	            from (select a.actor_id as actor_id, 
	                         f.film_id as film_id from actor as a
	                         cross join film as f
	                   order by 1, 2) as subquery_1)
	                   
	       , actual_combinations as --tabela pośrednia pokazująca tylko rzeczywiste kombinacje aktorów i filmów
	         (select actor_id
	               , film_id
                   , concat(actor_id,'-',film_id) as all_actual
                from film_actor)
                
	       , total_rentals as --tabela pośrednia pokazująca łączne wypożyczenia i przychody filmów
	         (select film_id as film_id
	               , count(r.rental_id) as count_rentals
	               , sum(amount) as sum_income 
	            from rental as r
                     join inventory as i on r.inventory_id = i.inventory_id
	            left join payment as p on r.rental_id = p.rental_id
	           group by film_id
	           order by count(r.rental_id) desc)
                                       	
      select pc.actor_id,
             pc.film_id,
             tr.count_rentals,
             tr.sum_income,
             pc.all_possible,
             ac.all_actual,
             case
             when ac.all_actual is null then 0 
             else 1 
             end as presence
        from possible_combinations as pc
             join total_rentals as tr on pc.film_id = tr.film_id
        left join actual_combinations as ac on pc.all_possible = ac.all_actual
	   order by 1, 2)
	
select a.actor_id
     , concat(first_name,' ',last_name) as "name"
	 , (select corr(sum_income, presence) as correlation_income --korelacja aktora i liczby wypożyczeń filmów
	      from (select sum_income, 
			           presence 
				  from actor_film_presence as afp
				 where a.actor_id = afp.actor_id) as subquery_5)
	 , (select avg(sum_income) as average_presence
		  from (select sum_income, 
				       presence 
				  from actor_film_presence as afp
				 where a.actor_id = afp.actor_id
				   and presence = 1) as subquery_6)
	 - (select avg(sum_income) as average_absence
		  from (select sum_income, 
				       presence 
				  from actor_film_presence as afp
				 where a.actor_id = afp.actor_id
				   and presence = 0) as subquery_7) as diff_avg_income --różnica średniej liczby wypożyczeń gdy aktora nie ma i gdy jest
  from actor as a
 order by correlation_income desc

