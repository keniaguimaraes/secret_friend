require 'rails_helper'

RSpec.describe MembersController, type: :controller do
  before(:each) do
    request.env["devise.mapping"] = Devise.mappings[:user]
    @current_user = FactoryGirl.create(:user)
    sign_in @current_user
  end

  describe "POST #create" do
    context 'User is the owner of campaign' do
      before(:each) do
        @campaign = create(:campaign, user: @current_user)
        @member_attributes = attributes_for(:member, campaign: @campaign)
        post :create, params: {member: @member_attributes}
      end

      it 'create member with right params' do
        expect(Member.last.name).to eql(@member_attributes[:name])
        expect(Member.last.email).to eql(@member_attributes[:email])
      end

      it 'associate member with right campaign' do
        expect(Member.last.campaign).to eql(@campaign)
      end

      it 'return http status success' do
        expect(response).to have_http_status(:success)
      end

      it 'return http status 422 when member has been created before' do
        post :create, params: {member: @member_attributes}
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to match("Membro já adicionado")
      end
    end

    context 'User is not the owner of campaign' do
      before(:each) do
        @campaign = create(:campaign)
        @member_attributes = attributes_for(:member, campaign: @campaign)
        post :create, params: {member: @member_attributes}
      end

      it 'returns http status 403 when user is not the owner of campaign' do
        expect(response).to have_http_status(:forbidden)
      end
    end

  end

  describe "DELETE #destroy" do
    before(:each) do
      request.env["HTTP_ACCEPT"] = 'application/json'
    end

    context "User is the Campaign Owner" do
      let(:other_member) { create(:member) }
      before(:each) do
        campaign = create(:campaign, user: @current_user)
        member = create(:member, campaign: campaign)
        delete :destroy, params: {id: member.id}
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it 'remove member from campaign' do
        expect(Campaign.members.count).to eq(0)
      end

      it 'remove member from database' do
        expect(Member.all.count).to eq(0)
      end

      it 'return 404 if member dont belongs to campaign' do
        expect(Campaign.members).not_to include(other_member)
      end
    end

    context "User isn't the Campaign Owner" do
      before(:each) do
        campaign = create(:campaign, user: @current_user)
        member = create(:member)
        delete :destroy, params: {id: member.id}
      end

      it "returns http forbidden" do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "PUT #update" do
    before(:each) do
      @member_attributes = attributes_for[:member]
    end

    context "when params are ok" do
      before(:each) do
        campaign = create(:campaign, user: @current_user)
        member = create(:member, campaign: campaign)
        put :update, params: {id: member.id, member: @member_attributes}
      end

      it 'returns http status success' do
        expect(response).to have_http_status(:success)
      end

      it 'member has the new attributes' do
        expect(Member.last.email).to eq(@member_attributes[:email])
      end

      it 'returns http status 422 when email was been recorded at campaign'
    end
  end

end
