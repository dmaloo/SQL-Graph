
--Questions I want to answer
--1 Who acted in which movie?
--
SELECT c.actor_name from movies a, moviesactor b, actor c
WHERE a.MovieId = b.movieid AND b.actorid = c.ActorID
AND a.Movie_Title = 'Jurassic Park'

SELECT p.personname FROM dbo.personnode p, movienode m,moviesactorlink a
where MATCH(m-(a)->p) AND m.movietitle = 'Jurassic Park'

--Most prolific actor
SELECT TOP 10 c.actor_name,COUNT(1) AS moviesactedin from movies a, moviesactor b, actor c
WHERE a.MovieId = b.movieid AND b.actorid = c.ActorID GROUP BY c.actor_name ORDER BY moviesactedin desc

SELECT TOP 10 p.personname,count(1) AS moviesactedin FROM dbo.personnode p, movienode m,moviesactorlink a
where MATCH(m-(a)->p) GROUP BY p.personname ORDER BY moviesactedin desc

--2 Actors who are directors
SELECT c.actor_name,a.Movie_Title from movies a 
INNER JOIN moviesactor b
ON a.MovieId = b.movieid
INNER JOIN actor c 
ON b.actorid = c.ActorID
INNER JOIN MoviesDirector d
ON a.MovieId = d.movieid 
INNER JOIN director e ON
d.directorid = e.directorid
AND e.director_name = c.actor_name

SELECT p1.personname, m.movietitle FROM personnode p1, movienode m, moviesactorlink a,moviesdirectorlink d
WHERE MATCH(m-(d)->p1 AND m-(a)->p1) 


