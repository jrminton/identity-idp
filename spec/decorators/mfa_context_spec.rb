require 'rails_helper'

describe MfaContext do
  let(:mfa) { MfaContext.new(user) }

  context 'with no user' do
    let(:user) {}

    describe '#auth_app_configuration' do
      it 'returns a AuthAppConfiguration object' do
        expect(mfa.auth_app_configuration).to be_a AuthAppConfiguration
      end
    end

    describe '#piv_cac_configuration' do
      it 'returns a PivCacConfiguration object' do
        expect(mfa.piv_cac_configuration).to be_a PivCacConfiguration
      end
    end

    describe '#phone_configurations' do
      it 'is empty' do
        expect(mfa.phone_configurations).to be_empty
      end
    end

    describe '#webauthn_configurations' do
      it 'is empty' do
        expect(mfa.webauthn_configurations).to be_empty
      end
    end
  end

  context 'with a user' do
    let(:user) { create(:user) }

    describe '#auth_app_configuration' do
      it 'returns a AuthAppConfiguration object' do
        expect(mfa.auth_app_configuration).to be_a AuthAppConfiguration
      end
    end

    describe '#piv_cac_configuration' do
      it 'returns a PivCacConfiguration object' do
        expect(mfa.piv_cac_configuration).to be_a PivCacConfiguration
      end
    end

    describe '#phone_configurations' do
      it 'mirrors the user relationship' do
        expect(mfa.phone_configurations).to eq user.phone_configurations
      end
    end

    describe '#webauthn_configurations' do
      context 'with no user' do
        let(:user) {}

        it 'is empty' do
          expect(mfa.webauthn_configurations).to be_empty
        end
      end
    end

    describe '#enabled_two_factor_configurations_count' do
      let(:count) { MfaContext.new(user).enabled_two_factor_configurations_count }

      context 'no 2FA configurations' do
        let(:user) { build(:user) }

        it 'returns zero' do
          expect(count).to eq 0
        end
      end

      context 'with phone configuration' do
        let(:user) { build(:user, :signed_up) }

        it 'returns 1' do
          expect(count).to eq 1
        end
      end

      context 'with PIV/CAC configuration' do
        let(:user) { build(:user, :with_piv_or_cac) }

        it 'returns 1' do
          expect(count).to eq 1
        end
      end

      context 'with authentication app configuration' do
        let(:user) { build(:user, :with_authentication_app) }

        it 'returns 1' do
          expect(count).to eq 1
        end
      end

      context 'with webauthn configuration' do
        let(:user) { build(:user, :with_webauthn) }

        it 'returns 1' do
          expect(count).to eq 1
        end
      end

      context 'with authentication app and webauthn configurations' do
        let(:user) { build(:user, :with_authentication_app, :with_webauthn) }

        it 'returns 2' do
          expect(count).to eq 2
        end
      end

      context 'with authentication app and phone configurations' do
        let(:user) { build(:user, :with_authentication_app, :signed_up) }

        it 'returns 2' do
          expect(count).to eq 2
        end
      end

      context 'with PIV/CAC and phone configurations' do
        let(:user) { build(:user, :with_piv_or_cac, :signed_up) }

        it 'returns 2' do
          expect(count).to eq 2
        end
      end
    end
  end
end
