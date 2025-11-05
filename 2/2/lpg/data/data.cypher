// === CLEAN START (optional) ===
// MATCH (n) DETACH DELETE n;

// === CONSTRAINTS ===
CREATE CONSTRAINT country_id IF NOT EXISTS FOR (c:Country) REQUIRE c.id IS UNIQUE;
CREATE CONSTRAINT studio_id  IF NOT EXISTS FOR (s:Studio)  REQUIRE s.id IS UNIQUE;
CREATE CONSTRAINT movie_id   IF NOT EXISTS FOR (m:Movie)   REQUIRE m.id IS UNIQUE;
CREATE CONSTRAINT cinema_id  IF NOT EXISTS FOR (c:Cinema)  REQUIRE c.id IS UNIQUE;
CREATE CONSTRAINT screen_id  IF NOT EXISTS FOR (s:Screening) REQUIRE s.id IS UNIQUE;

// === DATA ARRAYS ===
// COUNTRIES
WITH [
  {id:'country/us', label:'United States', isoCode:'US'},
  {id:'country/uk', label:'United Kingdom', isoCode:'GB'},
  {id:'country/fr', label:'France', isoCode:'FR'}
] AS rows
UNWIND rows AS r
MERGE (c:Country {id:r.id})
  SET c.label = r.label,
      c.isoCode = r.isoCode;

// STUDIOS
WITH [
  {id:'studio/warner-bros', name:'Warner Bros. Pictures', foundedYear:1923, moviesProduced:12500, basedIn:'country/us'}
] AS rows
UNWIND rows AS r
MERGE (s:Studio {id:r.id})
  SET s.name = r.name,
      s.foundedYear = r.foundedYear,
      s.moviesProduced = r.moviesProduced
WITH rows
UNWIND rows AS r
MATCH (s:Studio {id:r.id})
MATCH (c:Country {id:r.basedIn})
MERGE (s)-[:BASED_IN]->(c);

// MOVIES
WITH [
  {id:'movie/arrival',        title:'Arrival',        releaseYear:2016, durationMinutes:116, language:'en', producedBy:'studio/warner-bros'},
  {id:'movie/wonder-woman',   title:'Wonder Woman',   releaseYear:2017, durationMinutes:141, language:'en', producedBy:'studio/warner-bros'}
] AS rows
UNWIND rows AS r
MERGE (m:Movie {id:r.id})
  SET m.title = r.title,
      m.releaseYear = r.releaseYear,
      m.durationMinutes = r.durationMinutes,
      m.language = r.language
WITH rows
UNWIND rows AS r
MATCH (m:Movie  {id:r.id})
MATCH (s:Studio {id:r.producedBy})
MERGE (s)-[:PRODUCED]->(m);

// CINEMAS
WITH [
  {id:'cinema/arcadia-la',     name:'Arcadia LA',       city:'Los Angeles', countryCode:'US'},
  {id:'cinema/le-grand-paris', name:'Le Grand Paris',   city:'Paris',       countryCode:'FR'}
] AS rows
UNWIND rows AS r
MERGE (c:Cinema {id:r.id})
  SET c.name = r.name,
      c.city = r.city,
      c.countryCode = r.countryCode;

// SCREENINGS
WITH [
  {id:'screening/arr-la-2024-06-02-1800', movie:'movie/arrival',       cinema:'cinema/arcadia-la',     date:'2024-06-02', time:'18:00:00', language:'en'},
  {id:'screening/ww-par-2024-06-03-1900', movie:'movie/wonder-woman',  cinema:'cinema/le-grand-paris', date:'2024-06-03', time:'19:00:00', language:'fr'}
] AS rows
UNWIND rows AS r
MERGE (s:Screening {id:r.id})
  SET s.date = date(r.date),
      s.time = time(r.time),
      s.language = r.language
WITH rows
UNWIND rows AS r
MATCH (scr:Screening {id:r.id})
MATCH (m:Movie {id:r.movie})
MATCH (c:Cinema {id:r.cinema})
MERGE (scr)-[:SHOWS]->(m)
MERGE (scr)-[:TAKES_PLACE_AT]->(c);

// OPTIONAL: cinema -> country
WITH 'apply' AS _
MATCH (ci:Cinema)
MATCH (co:Country {isoCode:ci.countryCode})
MERGE (ci)-[:LOCATED_IN]->(co);

RETURN 'LPG import finished' AS status;
