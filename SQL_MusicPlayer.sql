-- 1. Who is the senior most employee based on job title?

SELECT TOP 1 * 
FROM employee
ORDER BY levels DESC;


-- 2. Which countries have the most Invoices?

SELECT COUNT(invoice_id) AS invoice, billing_country AS billing_country
FROM invoice
GROUP BY billing_country
ORDER BY billing_country DESC;

-- 3. What are top 3 values of total invoice?

SELECT TOP 3 *
FROM invoice
ORDER BY total DESC;


-- Q4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
--     Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals.

SELECT TOP 1 billing_city, SUM(total) AS total
FROM invoice
GROUP BY billing_city
ORDER BY total DESC;


-- 5. Who is the best customer? The customer who has spent the most money will be declared the best customer. 
--     Write a query that returns the person who has spent the most money.

SELECT TOP 1 
    c.customer_id, 
    c.first_name, 
    c.last_name, 
    SUM(i.total) AS total
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total DESC;


-- 6. Write a query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A 

SELECT DISTINCT 
    customer.email, 
    customer.first_name, 
    customer.last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
JOIN track ON invoice_line.track_id = track.track_id
JOIN genre ON track.genre_id = genre.genre_id
WHERE genre.name = 'Rock'
ORDER BY customer.email;


-- 7. Let's invite the artists who have written the most rock music in our dataset. 
--     Write a query that returns the Artist name and total track count of the top 10 rock bands.

SELECT TOP 10 
    artist.artist_id, 
    artist.name, 
    COUNT(track.track_id) AS num_of_songs
FROM artist
JOIN album ON album.artist_id = artist.artist_id
JOIN track ON track.album_id = album.album_id
WHERE track.genre_id IN (
    SELECT genre_id 
    FROM genre
    WHERE name LIKE 'Rock'
)
GROUP BY artist.artist_id, artist.name
ORDER BY num_of_songs DESC;



-- 8. Return all the track names that have a song length longer than the average song length. 
--     Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.

SELECT name, milliseconds
FROM track
WHERE milliseconds > (SELECT AVG(milliseconds) as avg_track_length
		      	FROM track)
ORDER BY milliseconds DESC;

-- 9. Find how much amount spent by each customer on artists. Write a query to return the customer name, artist name, and total spent.


WITH best_selling_artist AS (
	SELECT TOP 1
		artist.artist_id AS artist_id, 
		artist.name AS artist_name, 
		SUM(invoice_line.unit_price * invoice_line.quantity) AS total_spent
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY artist.artist_id, artist.name
	ORDER BY total_spent DESC
)

SELECT TOP 1
	c.customer_id AS customer_id, 
	c.first_name AS name, 
	bsa.artist_name AS artist_name, 
	SUM(il.unit_price * il.quantity) AS total_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album al ON al.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = al.artist_id
GROUP BY c.customer_id, c.first_name, bsa.artist_name
ORDER BY total_spent DESC;



-- 10. We want to find out the most popular music Genre for each country. 
--      We determine the most popular genre as the genre with the highest amount of purchases. 
--      Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres.

WITH popular_genre AS 
(
	SELECT 
		COUNT(invoice_line.quantity) AS purchases, 
	 	customer.country, 
		genre.name AS genre_name,
		ROW_NUMBER() OVER (
			PARTITION BY customer.country 
			ORDER BY COUNT(invoice_line.quantity) DESC
		) AS row_num 
	FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY customer.country, genre.name
)

SELECT country, genre_name, purchases 
FROM popular_genre 
WHERE row_num = 1
ORDER BY country;


