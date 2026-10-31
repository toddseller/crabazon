## Ye Olde Online Shoppe

### User Stories
* User can see all items available for sale.  
* User can purchase any item available for sale.  
* User can see purchase history.  
* User can add items to a shopping cart.  
* User can remove items from the shopping cart.  
* User can can view detail information about an item.  

### Client User Stories  
* Client can add products to sell.  
* Client can remove products from sale.  
* Client can view total sales for an item, or total overall sales.  
* Client can see purchaser information.  
* Client can edit items. 
  
### Live Heroku Site Link
[Crabazon](https://crabazon.herokuapp.com)

### Schema Design for Online Shop
![Alt text](online-shop-schema.png)

### Wire Frames
![Alt text](homepage.png)
Home Page

![Alt text](category-view.png)
Category View

![Alt text](product-page.png)
Product Page

![Alt text](add-product-page.png)
Add Product Page

![Alt text](checkout.png)
Checkout Page

### Deployment

The site runs on the app host from a checkout of `master` in `~/crabazon`, against PostgreSQL 18. The `web` container runs the code copied into its image at build time, not the checkout, so every code change needs a build. To deploy:

```sh
git pull
docker tag crabazon-web:latest crabazon-web:previous
docker compose build web
docker compose run --rm web bin/rails db:migrate
docker compose up -d web
```

The migrate step does nothing when no migration is pending, so it runs on every deploy.

To roll back to the image that ran before: if the deploy ran a migration, first run `docker compose run --rm web bin/rails db:rollback`, while the new image is still current, since the old image doesn't have the migration's code to undo it. Then:

```sh
docker tag crabazon-web:previous crabazon-web:latest
docker compose up -d web
```

Settings live in `.env`. To keep the database password out of it, set `PGPASS_FILE` to a libpq password file on the host and leave the password out of `DATABASE_URL`:

```sh
PGPASS_FILE=/home/<user>/.pgpass
DATABASE_URL=postgres://crabazon_app@<new-db-host>:5432/crabazon
```

Compose mounts that file read-only into `web`. Without `PGPASS_FILE`, the password in `DATABASE_URL` works as before.

### Running the tests

The tests run in Docker on the same Ruby as production, against a throwaway PostgreSQL 18. From the project directory:

```sh
docker network create crabazon-test
docker run -d --name crabazon-test-db --network crabazon-test -e POSTGRES_PASSWORD=postgres postgres:18
docker run --rm --network crabazon-test \
  -v "$PWD":/app -w /app -v crabazon-test-gems:/usr/local/bundle \
  -e RAILS_ENV=test -e RACK_ENV=test -e DATABASE_URL=postgres://postgres:postgres@crabazon-test-db/shoppe_test \
  ruby:3.4.12 bash -c '
    apt-get update && apt-get install -y nodejs && bundle install &&
    bin/rails db:create db:schema:load && bundle exec rspec'
```

Run the last command again after a change; the `crabazon-test-gems` volume keeps the gems between runs. Node is installed because Rails needs a JavaScript runtime to boot. Clean up with:

```sh
docker rm -f crabazon-test-db && docker network rm crabazon-test && docker volume rm crabazon-test-gems
```
