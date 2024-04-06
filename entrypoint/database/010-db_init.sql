CREATE TABLE IF NOT EXISTS aircrafts (
   id INT PRIMARY KEY,
   tail VARCHAR(10) NOT NULL
);

CREATE TABLE IF NOT EXISTS airports (
   id INT PRIMARY KEY,
   code_iata CHAR(3),
   code_icao VARCHAR(6),
   country CHAR(2),
   municipality VARCHAR(200),
   name VARCHAR(200)
);

CREATE TABLE IF NOT EXISTS flights (
   id INT PRIMARY KEY,
   aircraft_id INT,
   airport_id1 INT,
   airport_id2 INT,
   takeoff TIMESTAMP,
   landing TIMESTAMP,
   cargo_load INT,
   cargo_offload INT
);
