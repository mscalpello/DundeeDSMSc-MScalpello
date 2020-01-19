//Mat Scalpello Dundeee University MSc Data Science 2020
//Copde examples used in project

//Load Node data into Neo4J
//Create a rollback point after 500 records have been loaded
USING PERIODIC COMMIT 500 
//Load a row from the .csv file
LOAD CSV WITH HEADERS FROM 'file:/// Filename here' AS row 
//Create a Node
CREATE (:Person {connectionid:row.PersonID,FullName:row.PersonLabel,Gender:row.PersonGender}) 

//Use an index to speed up edge creation
CREATE INDEX ON :Person(connectionid)

//load Edge Data 
USING PERIODIC COMMIT 500
//Load a row from the .csv file
LOAD CSV WITH HEADERS FROM 'file:/// Filename here' AS row 
//Match the source and target IDs referenced by the row
Match (p1:Person {connectionid: toString(row.connection1id)}) 
Match (p2:Person {connectionid: toString(row.connection2id)}) 
with p1,p2,row 
//Apoc call to create the relationship details and related types and properties
Call apoc.create.relationship(p1,row.connection,{},p2) yield rel 
return rel 

//create a pre 2017 sub graph
MATCH (a)-[r:KNOWS]->(b) 
WHERE r.year < 2017
MERGE (a)-[:SUB_GRAPH_TRAINING {year: r.year}]-(b);

//Create  a 2017-2018 sub graph
MATCH (a)-[r:KNOWS]->(b) 
WHERE r.year >= 2016 AND r.year < 2019
MERGE (a)-[:SUB_GRAPH_TEST {year: r.year}]-(b);

//Find negative links from one starting individual for up to three degrees
MATCH (p1:Person {FullName: 'Name Here' })
WHERE (p1)-[:Knows]-()
MATCH (p1)-[:Knows*2..3]-(p2)
WHERE not((p1)-[:Knows]-(p2))
RETURN id(p1) AS node1, id(p2) AS node2, 0 AS label

//All connected nodes within an individuals subgraph for two degrees 
MATCH (p1:Person {FullName: 'Name Here' })-[*2]-(p2:Person)-[]-(p3:Person)
//WHERE NOT (p2:Person)-[]-(p3:Person) 
RETURN id(p2) AS node1, id(p3) AS node2, 1 AS label        

//Export nodes and edges to gephi for an individual subgraph
//Make sure you specify the correct workspace
MATCH (p:Person {FullName:"Name here"})
CALL apoc.path.subgraphAll(p, {maxLevel:2}) YIELD nodes, relationships
WITH collect(nodes) + collect(relationships) as paths
call apoc.gephi.add(null,'workspace1', paths) yield nodes, relationships
return nodes, relationships