require 'rails_helper'

describe Idv::ComeBackLaterController do
  let(:user) { build_stubbed(:user, :signed_up) }
  let(:pending_profile_requires_verification) { true }

  before do
    user_decorator = instance_double(UserDecorator)
    allow(user_decorator).to receive(:pending_profile_requires_verification?).
      and_return(pending_profile_requires_verification)
    allow(user).to receive(:decorate).and_return(user_decorator)
    allow(subject).to receive(:current_user).and_return(user)
  end

  context 'user needs USPS address verification' do
    it 'renders the show template' do
      stub_analytics

      expect(@analytics).to receive(:track_event).with(Analytics::IDV_COME_BACK_LATER_VISIT)

      get :show

      expect(response).to render_template :show
    end
  end

  context 'user does not need USPS address verification' do
    let(:pending_profile_requires_verification) { false }

    it 'redirects to the account path' do
      get :show

      expect(response).to redirect_to account_path
    end
  end
end
