--shortest path between two people
SELECT STRING_AGG(toActor.PersonName, '->') WITHIN GROUP (GRAPH PATH) AS FriendConnections,
          LAST_VALUE(toActor.PersonName) WITHIN GROUP (GRAPH PATH) AS FriendName,
          COUNT(toActor.PersonName) WITHIN GROUP (GRAPH PATH) AS levels
FROM
          PersonNode AS fromActor,
          CoActorLink FOR PATH AS f,
          PersonNode FOR PATH AS toActor
WHERE
         --MATCH(SHORTEST_PATH(fromActor(-(f)->toActor)+))
		 MATCH(SHORTEST_PATH((toActor<-(f)-)+fromActor))
		 AND fromActor.PersonName = 'Harrison Ford'

--Query 2 people exactly two hops away
SELECT PersonName, Friends
FROM (
	SELECT
		Person1.Personname AS PersonName, 
		STRING_AGG(Person2.Personname, '->') WITHIN GROUP (GRAPH PATH) AS Friends,
		COUNT(Person2.Personname) WITHIN GROUP (GRAPH PATH) AS levels
	FROM
		PersonNode AS Person1,
		CoActorLink FOR PATH AS fo,
		PersonNode FOR PATH  AS Person2
	WHERE MATCH(SHORTEST_PATH(Person1(-(fo)->Person2){1,3}))
	AND Person1.Personname = 'Harrison Ford'
) Q
WHERE Q.levels = 2
--Connection between two specific people
SELECT PersonName, Friends, levels
FROM (	
	SELECT
		Person1.Personname AS PersonName, 
		STRING_AGG(Person2.Personname, '->') WITHIN GROUP (GRAPH PATH) AS Friends,
		LAST_VALUE(Person2.Personname) WITHIN GROUP (GRAPH PATH) AS LastNode,
		COUNT(Person2.Personname) WITHIN GROUP (GRAPH PATH) AS levels
	FROM
	PersonNode AS Person1,
		CoActorLink FOR PATH AS fo,
		PersonNode FOR PATH  AS Person2
	WHERE MATCH(SHORTEST_PATH(Person1(-(fo)->Person2)+))
	AND Person1.Personname = 'Harrison Ford'
) AS Q
WHERE Q.LastNode = 'Tom Cruise'
