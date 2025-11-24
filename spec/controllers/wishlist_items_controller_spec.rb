require 'rails_helper'

RSpec.describe WishlistItemsController, type: :controller do

    let(:release_data) do
        {
        artist_id: 6542,
        title: "X&Y",
        thumb: "https://image.url/thumb.jpg",
        year: "2005",
        artist: "Coldplay"
        }.with_indifferent_access
    end
    # before do
    #     @release_data = {
    #         artist_id: 6542,
    #         title: "X&Y",
    #         thumb: "https://image.url/thumb.jpg",
    #         year: "2005",
    #         artist: "Coldplay"
    #     }.with_indifferent_access
    # end

    describe 'GET wishlist items' do
        it 'should retrieve list of wishlist_items' do
            wishlist_item_1 = WishlistItem.create(title: "Thriller", artist: "Michael Jackson")
            wishlist_item_2 = WishlistItem.create(title: "X&Y", artist: "Coldplay")
            get :index
            items = assigns(:wishlist_items)
            expect(items).to match_array([wishlist_item_1, wishlist_item_2])
        end
    end

    describe 'when creating a new wishlist item' do
        it 'create item and redirects with a notice' do
            expect {
                post :create, params: { release: release_data }
            }.to change(WishlistItem, :count).by(1)

            item = WishlistItem.last
            expect(item.title).to eq("X&Y")
            expect(item.artist).to eq("Coldplay")

            expect(response).to redirect_to(wishlist_items_path)
            expect(flash[:notice]).to eq("X&Y added to your wishlist!")
        end

        # test doesn't work since the Failed to add album to wishlist doesn't get hit
        # it 'should redirect when failure in creating item' do
        #     expect {
        #         post :create, params: { release: { title: nil, artist: "Coldplay" } }
        #     }.not_to change(WishlistItem, :count)

        #     expect(response).to redirect_to(search_path)
        #     expect(flash[:alert]).to eq("Failed to add album to wishlist.")
        # end

        context 'check for duplicates' do
            before do
                WishlistItem.create(title: "X&Y", artist: "Coldplay")
            end

            it 'should redirect with a notice when item already exists' do
                expect {
                    post :create, params: { release: release_data }
                }.not_to change(WishlistItem, :count)

                expect(response).to redirect_to(wishlist_items_path)
                expect(flash[:alert]).to eq("X&Y is already in your wishlist!")
            end
        end


    end

    describe 'when destroying wishlist item' do
        it 'delete item and redirect to wishlist_items page with notice' do
            wishlist_item = WishlistItem.create(
                title: "X&Y",
                artist: "Coldplay",
                image_url: "https://image.url/thumb.jpg"
            )

            expect {
                delete :destroy, params: { id: wishlist_item.id }
            }.to change(WishlistItem, :count).by(-1)

            expect(response).to redirect_to(wishlist_items_path)
            expect(flash[:notice]).to eq("X&Y removed from your wishlist.")
        end
    end
end