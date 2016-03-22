require 'rails_helper'

RSpec.describe Product, type: :model do
	context "with two or more products" do 
		it 'orders product by created_at date' do 
			product = Product.create(name: Faker::Beer.name, description: Faker::Hipster.sentence, price: Faker::Commerce.price, quantity: Faker::Number.between(1,20), product_image: Faker::Avatar.image)
			p2 = Product.create(name: Faker::Beer.name, description: Faker::Hipster.sentence, price: Faker::Commerce.price, quantity: Faker::Number.between(1,20), product_image: Faker::Avatar.image)
			expect(Product.first).to eq(product)
		end
	end

	context "with an empty product name" do 
		it 'raises an error when attempting to create a product without a name' do 
			product = Product.create(description: "dkslfjkl", price: Faker::Commerce.price, quantity: Faker::Number.between(1,20), product_image: Faker::Avatar.image)

			expect(product.errors.full_messages).to include("Name can't be blank")
		end
	end

	context "with an empty product price" do 
		it 'raises an error when attempting to save a product without a price' do 
			product = Product.create(name: "beer for all", description: "dkslfjkl", quantity: Faker::Number.between(1,20), product_image: Faker::Avatar.image)

			expect(product.errors.full_messages).to include("Price can't be blank")
		end
	end

	context "with an empty product quantity" do 
		it 'raises an error when attempting to save a product without a price' do 
			product = Product.create(name: "beer for all", description: "dkslfjkl", price: Faker::Commerce.price, product_image: Faker::Avatar.image)

			expect(product.errors.full_messages).to include("Quantity can't be blank")
		end
	end
end
