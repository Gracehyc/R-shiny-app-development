--Start Q2
select name,Votes,city 
from zomato_rest 
where name like '%%' And Votes Between 0 And 100
--End Q2

--Start Q3
select name,latitude,Longitude 
from zomato_rest 
where latitude is NOT NULL
--End Q3

