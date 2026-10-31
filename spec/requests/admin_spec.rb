require 'rails_helper'

RSpec.describe 'Admin', type: :request do
  let!(:stouts) { Category.create!(name: 'Stouts') }
  let!(:ipa) { Product.create!(name: 'Stone IPA', description: 'Hoppy', price: 4.5, quantity: 5, product_image: 'https://example.com/ipa.png') }
  let(:product_params) { { name: 'Imperial Stout', description: 'Dark', price: 12.5, quantity: 3, product_image: 'https://example.com/stout.png' } }

  before { sign_in User.create!(name: 'Ada', email: 'ada@example.com', password: 'secret1', role: 'admin') }

  it 'lists the products on /admin' do
    get '/admin'

    expect(response.body).to include('Your Inventory!', 'Stone IPA')
  end

  it 'creates, updates and deletes a product' do
    post '/products', params: { product: product_params, category_ids: [stouts.id] }
    expect(response).to redirect_to('/admin')
    stout = Product.find_by!(name: 'Imperial Stout')
    expect(stout.categories).to eq([stouts])

    patch "/products/#{stout.id}", params: { product: product_params.merge(quantity: 9), category_ids: [stouts.id] }
    expect(response).to redirect_to('/admin')
    expect(stout.reload.quantity).to eq(9)

    delete "/products/#{stout.id}"
    expect(response).to redirect_to('/admin')
    expect(Product.exists?(stout.id)).to be(false)
  end

  it 'refuses to create a product without an image' do
    expect { post '/products', params: { product: product_params.merge(product_image: ''), category_ids: [stouts.id] } }.not_to change(Product, :count)
    expect(response.body).to include('Opps! Something went wrong')

    get "/products/#{ipa.id}/edit"
    expect(response.body).not_to include('Opps! Something went wrong')
  end

  it 'refuses to remove the image from a product' do
    patch "/products/#{ipa.id}", params: { product: product_params.merge(product_image: ''), category_ids: [stouts.id] }
    expect(ipa.reload.product_image).to eq('https://example.com/ipa.png')
    expect(response.body).to include('Opps! Something went wrong')
  end

  it 'creates a product in no category' do
    post '/products', params: { product: product_params }

    expect(response).to redirect_to('/admin')
    expect(Product.find_by!(name: 'Imperial Stout').categories).to be_empty
  end

  it 'removes every category when none is ticked' do
    ipa.categories << stouts

    patch "/products/#{ipa.id}", params: { product: product_params }

    expect(ipa.reload.categories).to be_empty
  end

  it 'leaves the categories alone when an update is refused' do
    lagers = Category.create!(name: 'Lagers')
    ipa.categories << stouts

    patch "/products/#{ipa.id}", params: { product: product_params.merge(product_image: ''), category_ids: [lagers.id] }

    expect(ipa.reload.categories).to eq([stouts])
  end

  it 'gives the product table a header cell for every column' do
    get '/admin'

    table = Nokogiri::HTML(response.body).at('table')
    expect(table.css('thead th').size).to eq(table.at('tbody tr').css('td').size)
  end

  it 'links from /admin to the category list' do
    get '/admin'

    expect(Nokogiri::HTML(response.body).at('a[href="/categories"]')).not_to be_nil
  end

  it 'lists the categories with their edit and delete links' do
    get '/categories'

    page = Nokogiri::HTML(response.body)
    expect(page.at('.category-name').text).to eq('stouts')
    expect(page.at(%(a[href="/categories/#{stouts.id}/edit"]))).not_to be_nil
    expect(page.at(%(a[href="/categories/#{stouts.id}"][data-method="delete"]))).not_to be_nil
    expect(page.at('a[href="/categories/new"]')).not_to be_nil
  end

  it 'has a name field on the add and edit pages' do
    ['/categories/new', "/categories/#{stouts.id}/edit"].each do |path|
      get path

      expect(Nokogiri::HTML(response.body).at('form input.category-name[name="category[name]"]')).not_to be_nil, path
    end
  end

  it 'creates and renames a category' do
    post '/categories', params: { category: { name: 'Lagers' } }
    expect(response).to redirect_to('/categories')
    follow_redirect!
    expect(response.body).to include('Category successfully created!')
    lagers = Category.find_by!(name: 'lagers')

    patch "/categories/#{lagers.id}", params: { category: { name: 'Pilsners' } }

    expect(response).to redirect_to('/categories')
    expect(lagers.reload.name).to eq('pilsners')
  end

  it 'deletes a category and keeps its products' do
    ipa.categories << stouts

    delete "/categories/#{stouts.id}"

    expect(response).to redirect_to('/categories')
    follow_redirect!
    expect(response.body).to include('Category successfully deleted!')
    expect(Category.exists?(stouts.id)).to be(false)
    expect(ipa.reload.categories).to be_empty
  end

  it 'refuses a blank name' do
    expect { post '/categories', params: { category: { name: '  ' } } }.not_to change(Category, :count)
    expect(response.body).to include('Opps! Something went wrong')
  end

  it 'refuses to rename a category to a name in use' do
    lagers = Category.create!(name: 'Lagers')

    patch "/categories/#{lagers.id}", params: { category: { name: 'Stouts' } }

    expect(lagers.reload.name).to eq('lagers')
    expect(response.body).to include('Opps! Something went wrong')
  end

  it 'stores names trimmed and in lowercase, and compares them that way' do
    post '/categories', params: { category: { name: '  craft BEER ' } }
    expect(Category.find_by(name: 'craft beer')).not_to be_nil

    expect { post '/categories', params: { category: { name: 'STOUTS' } } }.not_to change(Category, :count)
  end
end
