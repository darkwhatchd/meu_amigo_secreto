# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MembersController, type: :controller do
  include Devise::Test::ControllerHelpers

  before(:each) do
    # request.env["HTTP_ACCEPT"] = 'application/json'

    @request.env['devise.mapping'] = Devise.mappings[:user]
    @current_user = FactoryBot.create(:user)
    sign_in @current_user
    @current_campaign = create(:campaign, user: @current_user)
  end

  describe 'POST #create' do
    before(:each) do
      @member_attributes = attributes_for(:member, campaign: @current_campaign)
      post :create, params: { member: @member_attributes }
    end
    it 'Member created with right attributes' do
      expect(Member.last.name).to eq(@member_attributes[:name])
      expect(Member.last.email).to eq(@member_attributes[:email])
    end

    it 'Member is associated with right campaign' do
      expect(Member.last.campaign).to eq(@member_attributes[:campaign])
    end

    it 'Return Success' do
      # @member_attributes = attributes_for(:member, campaign: @current_campaign)
      # post :create, params: { member: @member_attributes }
      expect(response).to have_http_status(:success)
    end

    it 'If member already exist in this campaign, return status 422' do
      same_member = Member.new(name: Member.last.name, email: Member.last.email, campaign: Member.last.campaign)
      post :create, params: { member: same_member }
      expect(response).to have_http_status(422)
    end

    it 'User is not the campaign owner' do
      campaign = create(:campaign)
      member = attributes_for(:member, campaign: campaign)
      post :create, params: { member: member }
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'DELETE #destroy' do
    before(:each) do
      request.env['HTTP_ACCEPT'] = 'application/json'
    end

    context 'User is the campaign owner' do
      it 'returns http success' do
        campaign = create(:campaign, user: @current_user)
        member = create(:member, campaign: campaign)
        delete :destroy, params: { id: member.id }
        expect(response).to have_http_status(:success)
      end

      it 'Member was removed from campaign' do
        campaign = create(:campaign, user: @current_user)
        member = create(:member, campaign: campaign)
        delete :destroy, params: { id: member.id }
        expect(Member.last.id).not_to eql(member[:id])
      end

      it 'Member isnt in this Campaign' do
        member = create(:member)
        delete :destroy, params: { id: member.id }
        expect(reponse).to have_http_status(404)
      end
    end

    context "User isn't the campaign Owner" do
      it 'Return error 403' do
        campaign = create(:campaign)
        member = create(:member, campaign: campaign)
        delete :destroy, params: { id: member.id }
        expect(response).to have_http_status(403)
      end
    end
  end

  describe 'PUT #update' do
    before(:each) do
      @new_member_attributes = attributes_for(:member)
      request.env['HTTP_ACCEPT'] = 'application/json'
    end

    context 'User is the Campaign Owner' do
      before(:each) do
        campaign = create(:campaign, user: @current_user)
        member = create(:member, campaign: campaign)
        put :update, params: { id: member.id, member: @new_member_attributes }
      end

      it 'Return http success' do
        expect(response).to have_http_status(:success)
      end

      it 'Member have the new attributes' do
        expect(Member.last.name).to eq(@new_member_attributes[:name])
        expect(Member.last.email).to eq(@new_member_attributes[:email])
      end
    end

    context "User isn't the Campaign Owner" do
      it 'returns http forbidden' do
        campaign = create(:campaign)
        member = create(:member, campaign: campaign)
        put :update, params: { id: member.id, member: @new_member_attributes }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
