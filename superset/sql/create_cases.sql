CREATE TABLE cases
(
	  id serial NOT NULL,
	  dateRep date,
	  day integer,
	  month integer,
	  year integer,
	  cases integer,
	  deaths integer,
	  countriesAndTerritories character varying(50),
	  geoId character varying(50),
	  countryterritoryCode character varying(50),
	  popData2018 float,
	  continentExp character varying(255),
	  CONSTRAINT cases_pkey PRIMARY KEY (id)
)

