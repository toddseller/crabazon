require 'rails_helper'

RSpec.describe 'Admin access', type: :request, aggregate_failures: true do
  let!(:stouts) { Category.create!(name: 'Stouts') }
  let!(:ipa) { Product.create!(name: 'Stone IPA', description: 'Hoppy', price: 4.5, quantity: 5, product_image: 'https://example.com/ipa.png') }
  let(:product_params) { { name: 'Hijacked', description: 'x', price: 1, quantity: 1, product_image: 'https://example.com/x.png' } }

  let(:guarded_requests) do
    [
      [:get, '/admin'],
      [:get, '/products/new'],
      [:post, '/products', { product: product_params, category_ids: [stouts.id] }],
      [:get, "/products/#{ipa.id}/edit"],
      [:patch, "/products/#{ipa.id}", { product: product_params, category_ids: [stouts.id] }],
      [:delete, "/products/#{ipa.id}"],
      [:get, '/categories/new'],
      [:post, '/categories', { category: { name: 'Hijacked' } }],
      [:get, "/categories/#{stouts.id}/edit"],
      [:patch, "/categories/#{stouts.id}", { category: { name: 'Hijacked' } }],
      [:delete, "/categories/#{stouts.id}"]
    ]
  end

  def catalog
    [Product.order(:id).pluck(:name, :quantity), Category.order(:id).pluck(:name)]
  end

  it 'sends anonymous visitors to sign in and changes nothing' do
    guarded_requests.each do |verb, path, params|
      expect { send(verb, path, params: params) }.not_to change { catalog }, "#{verb.upcase} #{path}"
      expect(response).to redirect_to('/users/sign_in'), "#{verb.upcase} #{path}"
    end
  end

  it 'sends customers home with a message and changes nothing' do
    sign_in User.create!(name: 'Cara', email: 'cara@example.com', password: 'secret1')

    guarded_requests.each do |verb, path, params|
      expect { send(verb, path, params: params) }.not_to change { catalog }, "#{verb.upcase} #{path}"
      expect(response).to redirect_to('/index'), "#{verb.upcase} #{path}"
      expect(flash[:alert]).to eq('That page is for admins.')
    end
  end
end
