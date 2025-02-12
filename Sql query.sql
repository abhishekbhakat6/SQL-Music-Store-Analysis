        /* Question set : Easy */

/* Q1: Who is the senior most employee based on job title? */

Select * from employee
order by levels desc 
limit 1;

-- Ans : Madan Mohan

/* Q2: Which country have the most invoices? */

select count(*) as most_invoice, billing_country
from invoice
group by billing_country
order by most_invoice desc
limit 1;

/* Ans: USA */

/* Q3: What are the top three values of total invoice? */

select total 
from invoice
order by total desc
limit 3;

/* Ans: 23.7 , 19.8, 19.8 */

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals. */

select billing_city, sum(total) as invoice_total
from invoice
group by billing_city
order by invoice_total desc;

/* Ans: Parague */

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money. */

select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as total_spend
from customer
join invoice on 
customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total_spend desc
limit 1;

/* Ans : R. Madhav */

        /* Question set : Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */	

select distinct email, first_name, last_name
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in 
  (select track_id 
  from track 
  join genre on track.genre_id = genre.genre_id
  where genre.name = 'Rock')
order by email asc;  

/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */


select artist.artist_id, artist.name, count(artist.artist_id) as no_of_songs
from artist
join album on artist.artist_id = album.artist_id
join track on album.album_id = track.album_id
join genre on track.genre_id = genre.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by no_of_songs desc
limit 10;

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select name, milliseconds
 from track
 where milliseconds > ( select avg(milliseconds)
 from track)
 order by milliseconds desc;

        /* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */		

with best_selling_artist  as(
select artist.artist_id as artist_id, artist.name as artist_name,
sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
from invoice_line
join track on invoice_line.track_id = track.track_id
join album on track.album_id = album.album_id
join artist on album.artist_id = artist.artist_id
group by artist.artist_id
order by total_sales desc
limit 1
)
   select c.customer_id, c.first_name || ' ' || c.last_name as Name, bsa.artist_name,
   sum(il.unit_price*il.quantity) as amount_spend
   from invoice i
   join customer c on c.customer_id = i.customer_id
   join invoice_line il on i.invoice_id = il.invoice_id
   join track t on il.track_id = t.track_id
   join album al on t.album_id = al.album_id
   join best_selling_artist bsa on al.artist_id = bsa.artist_id
   group by c.customer_id, c.first_name || ' ' || c.last_name, bsa.artist_name
   order by amount_spend desc;

/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

with recursive
	sales_per_country as(
		select count(*) as purchases_per_genre, customer.country, genre.name, genre.genre_id
		from invoice_line
		join invoice on invoice.invoice_id = invoice_line.invoice_id
		join customer on customer.customer_id = invoice.customer_id
		join track on track.track_id = invoice_line.track_id
		join genre on genre.genre_id = track.genre_id
		group by customer.country, genre.name, genre.genre_id
	    order by customer.country
	),
	max_genre_per_country as (select max(purchases_per_genre) as max_genre_number, country
		from sales_per_country
		group by country
		order by country)

select sales_per_country.* 
from sales_per_country
join max_genre_per_country on sales_per_country.country = max_genre_per_country.country
where sales_per_country.purchases_per_genre = max_genre_per_country.max_genre_number;

/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

with recursive 
customer_with_country as(
select customer.customer_id, first_name, last_name, billing_country, sum(total) as total_spend
from invoice
join customer on invoice.customer_id = customer.customer_id
group by customer.customer_id, first_name, last_name, billing_country
order by customer.customer_id, total_spend desc
),

  country_max_spending as (
      select billing_country, max(total_spend) as max_spending
	  from customer_with_country
	  group by billing_country
	 )

	   select cwc.billing_country, cwc.first_name, cwc.last_name, cwc.customer_id
	   from customer_with_country cwc
	   join country_max_spending cms on cwc.billing_country = cms.billing_country
	   where cwc.total_spend = cms.max_spending
	   order by cwc.billing_country;
	   
	 