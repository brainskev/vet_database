/*Queries that provide answers to the questions from all projects.*/

-- Find all animals whose name ends in "mon".
SELECT * from animals WHERE name LIKE '%mon';
-- List the name of all animals born between 2016 and 2019.
SELECT name from animals WHERE date_of_birth BETWEEN '2016-01-01' AND '2019-01-01';
-- List the name of all animals that are neutered and have less than 3 escape attempts.
SELECT name from animals WHERE neutered = true AND escape_attempts <3;
-- List the date of birth of all animals named either "Agumon" or "Pikachu".
SELECT date_of_birth from animals WHERE name IN ('Agumon', 'Pikachu');
-- List name and escape attempts of animals that weigh more than 10.5kg
SELECT name, escape_attempts from animals WHERE weight_kg > 10.5;
-- Find all animals that are neutered.
SELECT * from animals WHERE neutered = true;
-- Find all animals not named Gabumon.
SELECT * from animals WHERE name <> 'Gabumon';
-- Find all animals with a weight between 10.4kg and 17.3kg (including the animals with the weights that equals precisely 10.4kg or 17.3kg)
SELECT * from animals WHERE weight_kg BETWEEN 10.4 AND 17.3;

BEGIN TRANSACTION;

-- Update the animals table by setting the species column to digimon for all animals that have a name ending in mon.
UPDATE animals
SET species = 'digimon'
WHERE name LIKE '%mon';

-- Update the animals table by setting the species column to pokemon for all animals that don't have species already set.
UPDATE animals
SET species = 'pokemon'
WHERE species IS NULL;

COMMIT;

-- Verify that change was made and persists after commit.
SELECT * FROM animals;

BEGIN;

-- Delete all records in the animals table
DELETE FROM animals;

-- Rollback the transaction
ROLLBACK;

-- Verify if all records in the animals table still exist
SELECT * FROM animals;

BEGIN TRANSACTION;
    
-- Delete all animals born after Jan 1st, 2022
DELETE FROM animals WHERE date_of_birth > '2022-01-01';

-- Create a savepoint
SAVEPOINT weight_update;

-- Update all animals' weight to be their weight multiplied by -1
UPDATE animals SET weight_kg = weight_kg * -1;

-- Rollback to savepoint
ROLLBACK TO weight_update;

-- Update all animals' weights that are negative to be their weight multiplied by -1
UPDATE animals SET weight_kg = weight_kg * -1 WHERE weight_kg < 0;

COMMIT;

-- Verify that change was made and persists after commit.
SELECT * FROM animals;

-- How many animals are there?
SELECT COUNT(*) FROM animals;
-- How many animals have never tried to escape?
SELECT COUNT(*) FROM animals WHERE escape_attempts = 0;
-- What is the average weight of animals?
SELECT AVG(weight_kg) FROM animals;
-- Who escapes the most, neutered or not neutered animals?
SELECT neutered, SUM(escape_attempts) as total_escapes
FROM animals
GROUP BY neutered
ORDER BY total_escapes DESC
LIMIT 1;
-- What is the minimum and maximum weight of each type of animal?
SELECT species, MIN(weight_kg) as min_weight, MAX(weight_kg) as max_weight
FROM animals
GROUP BY species;
-- What is the average number of escape attempts per animal type of those born between 1990 and 2000?
SELECT species, AVG(escape_attempts) as avg_escape_attempts
FROM animals
WHERE date_of_birth BETWEEN '1990-01-01' AND '2000-12-31'
GROUP BY species;
-- What animals belong to Melody Pond
SELECT animals.name
FROM animals
JOIN owners ON animals.owner_id = owners.id
WHERE owners.full_name = 'Melody Pond';
-- List of all animals that are pokemon (their type is Pokemon).
SELECT animals.name
FROM animals
JOIN species ON animals.species_id = species.id
WHERE species.name = 'Pokemon';
-- List all owners and their animals, remember to include those that don't own any animal.
SELECT owners.full_name, animals.name
FROM owners
LEFT JOIN animals ON owners.id = animals.owner_id
ORDER BY owners.full_name;
-- How many animals are there per species?
SELECT species.name, COUNT(animals.id) AS count
FROM animals
JOIN species ON animals.species_id = species.id
GROUP BY species.name;
-- List all Digimon owned by Jennifer Orwell.
SELECT animals.name
FROM animals
JOIN species ON animals.species_id = species.id
JOIN owners ON animals.owner_id = owners.id
WHERE species.name = 'Digimon' AND owners.full_name = 'Jennifer Orwell';
-- List all animals owned by Dean Winchester that haven't tried to escape
SELECT animals.name
FROM animals
JOIN owners ON animals.owner_id = owners.id
WHERE owners.full_name = 'Dean Winchester' AND animals.escape_attempts = 0;
-- Who owns the most animals?
SELECT owners.full_name, COUNT(animals.id) AS count
FROM owners
LEFT JOIN animals ON owners.id = animals.owner_id
GROUP BY owners.full_name
ORDER BY count DESC
LIMIT 1;

-- Who was the last animal seen by William Tatcher?
SELECT a.name
FROM animals a
INNER JOIN visits v ON a.id = v.animal_id
WHERE v.vet_id = (SELECT id FROM vets WHERE name = 'William Tatcher')
ORDER BY v.visit_date DESC
LIMIT 1;
-- How many different animals did Stephanie Mendez see?
SELECT COUNT(DISTINCT animal_id)
FROM visits
WHERE vet_id = (SELECT id FROM vets WHERE name = 'Stephanie Mendez');
-- List all vets and their specialties, including vets with no specialties.
SELECT v.name, s.name AS specialty
FROM vets v
LEFT JOIN specializations sp ON v.id = sp.vet_id
LEFT JOIN species s ON sp.species_id = s.id
ORDER BY v.name;
-- List all animals that visited Stephanie Mendez between April 1st and August 30th, 2020.
SELECT a.name
FROM animals a
INNER JOIN visits v ON a.id = v.animal_id
WHERE v.vet_id = (SELECT id FROM vets WHERE name = 'Stephanie Mendez')
AND v.visit_date BETWEEN '2020-04-01' AND '2020-08-30';
-- What animal has the most visits to vets?
SELECT a.name, COUNT(*) AS num_visits
FROM animals a
INNER JOIN visits v ON a.id = v.animal_id
GROUP BY a.id
ORDER BY num_visits DESC
LIMIT 1;
-- Who was Maisy Smith's first visit?
SELECT v.name, MIN(vi.visit_date) AS first_visit
FROM vets v
INNER JOIN visits vi ON v.id = vi.vet_id
WHERE v.name = 'Maisy Smith'
GROUP BY v.name;
-- Details for most recent visit: animal information, vet information, and date of visit.
SELECT a.name AS animal_name, vt.name AS vet_name, visit_date
FROM animals a
INNER JOIN visits v ON a.id = v.animal_id
INNER JOIN vets vt ON v.vet_id = vt.id
WHERE v.visit_date = (SELECT MAX(visit_date) FROM visits)
LIMIT 1;
-- How many visits were with a vet that did not specialize in that animal's species?
SELECT COUNT(*)
FROM visits v
LEFT JOIN specializations sp ON v.vet_id = sp.vet_id AND v.animal_id = sp.species_id
WHERE sp.vet_id IS NULL;
-- What specialty should Maisy Smith consider getting? Look for the species she gets the most.
SELECT a.species_id, s.name AS species_name, COUNT(*) AS num_visits
FROM visits v
INNER JOIN animals a ON v.animal_id = a.id
INNER JOIN species s ON a.species_id = s.id
INNER JOIN vets vt ON v.vet_id = vt.id
WHERE vt.name = 'Maisy Smith'
GROUP BY a.species_id, species_name
ORDER BY num_visits DESC
LIMIT 1;







