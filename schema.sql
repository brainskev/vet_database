/* Database schema to keep the structure of entire database. */

CREATE TABLE animals (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    date_of_birth DATE,
    escape_attempts INTEGER,
    neutered BOOLEAN,
    weight_kg DECIMAL(5,2),
    species_id INTEGER REFERENCES species(id),
    owner_id INTEGER REFERENCES owners(id)
);


CREATE TABLE owners (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(255),
    age INTEGER
);

CREATE TABLE species (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255)
);

CREATE TABLE vets (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255),
  age INTEGER,
  date_of_graduation DATE
);

CREATE TABLE specializations (
  id SERIAL PRIMARY KEY,
  vet_id INTEGER REFERENCES vets(id),
  species_id INTEGER REFERENCES species(id)
);

CREATE TABLE visits (
  id SERIAL PRIMARY KEY,
  animal_id INTEGER REFERENCES animals(id),
  vet_id INTEGER REFERENCES vets(id),
  visit_date DATE NOT NULL
);

-- To optimize the query SELECT COUNT(*) FROM visits where animal_id = 4;
CREATE INDEX animal_id_index ON visits (animal_id);
-- to optimize the query SELECT * FROM visits where vet_id = 2;
CREATE INDEX vet_id_index ON visits (vet_id);
-- To optimize the query SELECT * FROM owners where email = 'owner_18327@mail.com';
CREATE INDEX email_index ON owners (email);

