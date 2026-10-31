# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
User.create(name: 'tom', email: 'tom@tom.com', password: 'tomtom', role: 'user', confirmed_at: Time.current)
User.create(name: 'tim', email: 'tim@tim.com', password: 'timtim', role: 'admin', confirmed_at: Time.current)

5.times {Category.create!(name: Faker::Commerce.department)}
15.times {Category.all.shuffle.first.products.create!(name: Faker::Beer.name, description: Faker::Hipster.sentence, price: Faker::Commerce.price, quantity: Faker::Number.between(from: 1, to: 20), product_image: Faker::Avatar.image)}
