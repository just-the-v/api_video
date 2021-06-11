# My Api - youtube 
## Setup le projet

Une fois dans le repo vous pouvez setup le dockerfile avec `docker-compose up --build`

Le projet set lance sur le port 3000

## Lancer les Tests Unitaires

L'application a entièrement été faite en TDD avec RSPEC, nous comptons 133 tests sur l'ensemble des endpoints
 
Une fois le container lancé, vous pouvez run `docker exec -ti my_api bin/rspec -f d` 
