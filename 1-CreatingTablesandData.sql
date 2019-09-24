USE  MovieData_Demo;
go

 DROP TABLE IF EXISTS PersonNode;
  GO
  CREATE TABLE PersonNode (
    PersonID INT IDENTITY(1,1) NOT NULL    PRIMARY KEY,
    PersonName varchar(500)  ) AS NODE;
	 
sp_help 'PersonNode'

SELECT is_node, is_edge FROM sys.tables
  WHERE name = 'PersonNode';

SELECT name, graph_type, graph_type_desc 
  FROM sys.columns
  WHERE object_id = OBJECT_ID('PersonNode');

INSERT INTO PersonNode (PersonName) 
SELECT actor_name FROM MovieData.dbo.Actor
UNION 
SELECT director_name FROM MovieData.dbo.Director

SELECT * FROM PersonNode

DROP TABLE IF EXISTS MovieNode;
GO
CREATE TABLE MovieNode (
    MovieID INT PRIMARY KEY,
    MovieTitle varchar(500) NOT NULL,
    MovieLanguage varchar(500) NULL,
	MovieCountry varchar(500) NULL,
	MovieFacebookLikes INT NULL
  ) AS NODE;


SELECT is_node, is_edge FROM sys.tables
  WHERE name = 'MovieNode';

SELECT name, graph_type, graph_type_desc 
  FROM sys.columns
  WHERE object_id = OBJECT_ID('MovieNode');

INSERT INTO MovieNode (movieid,movietitle,movielanguage,moviecountry,moviefacebooklikes) 
SELECT [MovieId],[Movie_Title],[Language],[Country],movie_facebook_likes FROM MovieData.[dbo].[movies]

SELECT * FROM MovieNode
sp_help 'MovieNode'

DROP TABLE IF EXISTS MoviesActorLink;
  GO
  CREATE TABLE MoviesActorLink (
    Link BIT NOT NULL DEFAULT 0,
	MovieActorLevel smallint NULL,
	MovieActorFacebooklikes DECIMAL NULL,
	CONSTRAINT EDG_MoviesWithActor CONNECTION (MovieNode TO PersonNode)
  ) AS EDGE;

SELECT is_node, is_edge FROM sys.tables
  WHERE name = 'MoviesActorLink';
 SELECT name, graph_type, graph_type_desc 
  FROM sys.columns
  WHERE object_id = OBJECT_ID('MoviesActorLink');
 
 sp_help 'MoviesActorLink'

 SELECT OBJECT_NAME(parent_object_id) as ParentObjectIdTable, *
	FROM sys.edge_constraints;


 INSERT INTO MoviesActorLink ($from_id, $to_id,movieactorlevel,movieactorfacebooklikes) 
 SELECT a.$node_id, p.$node_id,c.actor_level,c.actor_facebook_likes FROM dbo.MovieNode a
 INNER JOIN MovieData.dbo.MoviesActor c ON a.movieid = c.movieid
 INNER JOIN MovieData.dbo.Actor b ON c.actorid = b.actorid
 INNER JOIN dbo.PersonNode p ON b.actor_name = p.personname 

 SELECT * FROM dbo.MoviesActorLink

 