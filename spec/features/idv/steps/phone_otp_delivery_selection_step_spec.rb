require 'rails_helper'

feature 'IdV phone OTP deleivery method selection' do
  include IdvStepHelper

  context 'the users chooses sms' do
    it 'sends an sms and redirects to otp verification' do
      expect(VoiceOtpSenderJob).to_not receive(:perform_later)
      expect(SmsOtpSenderJob).to receive(:perform_later)

      start_idv_from_sp
      complete_idv_steps_before_phone_otp_delivery_selection_step
      choose_idv_otp_delivery_method_sms

      expect(page).to have_content(t('two_factor_authentication.header_text'))
      expect(current_path).to eq(idv_otp_verification_path)
    end
  end

  context 'the user chooses voice' do
    it 'sends a voice call and redirects to otp verification' do
      expect(VoiceOtpSenderJob).to receive(:perform_later)
      expect(SmsOtpSenderJob).to_not receive(:perform_later)

      start_idv_from_sp
      complete_idv_steps_before_phone_otp_delivery_selection_step
      choose_idv_otp_delivery_method_voice

      expect(page).to have_content(t('two_factor_authentication.header_text'))
      expect(current_path).to eq(idv_otp_verification_path)
    end
  end

  context 'the user does not make a selection' do
    it 'does not send a voice call or sms and renders an error' do
      expect(VoiceOtpSenderJob).to_not receive(:perform_later)
      expect(SmsOtpSenderJob).to_not receive(:perform_later)

      start_idv_from_sp
      complete_idv_steps_before_phone_otp_delivery_selection_step
      click_on t('idv.buttons.send_confirmation_code')

      expect(page).to have_content(t('idv.errors.unsupported_otp_delivery_method'))
      expect(current_path).to eq(idv_otp_delivery_method_path)
    end
  end

  context 'with a non-US number' do
    let(:bahamas_phone) { '+12423270143' }

    before do
      start_idv_from_sp
      complete_idv_steps_before_phone_step
      fill_out_phone_form_ok(bahamas_phone)
      click_idv_continue
    end

    it 'displays an error message' do
      expect(VoiceOtpSenderJob).to_not receive(:perform_later)
      expect(SmsOtpSenderJob).to_not receive(:perform_later)
      expect(page).to have_content(t('errors.messages.must_have_us_country_code'))
      expect(current_path).to eq(idv_phone_path)
    end
  end

  it 'does not modify the otp column on the user model when sending an OTP' do
    user = user_with_2fa

    start_idv_from_sp
    complete_idv_steps_before_phone_otp_delivery_selection_step(user)

    old_direct_otp = user.direct_otp
    choose_idv_otp_delivery_method_sms
    user.reload

    expect(user.direct_otp).to eq(old_direct_otp)
  end

  it 'redirects back to the step with an error if twilio raises an error' do
    user = user_with_2fa

    start_idv_from_sp
    complete_idv_steps_before_phone_otp_delivery_selection_step(user)

    generic_exception = Twilio::REST::RestError.new(
      '', FakeTwilioErrorResponse.new(123)
    )
    allow(SmsOtpSenderJob).to receive(:perform_later).and_raise(generic_exception)

    choose_idv_otp_delivery_method_sms

    expect(page).to have_content(t('errors.messages.otp_failed'))
    expect(page).to have_current_path(idv_phone_path)

    fill_out_phone_form_ok
    click_idv_continue

    calling_area_exception = Twilio::REST::RestError.new(
      '', FakeTwilioErrorResponse.new(21_215)
    )
    allow(SmsOtpSenderJob).to receive(:perform_later).and_raise(calling_area_exception)

    choose_idv_otp_delivery_method_sms

    expect(page).to have_content(t('errors.messages.invalid_calling_area'))
    expect(page).to have_current_path(idv_phone_path)
  end

  context 'cancelling IdV' do
    it_behaves_like 'cancel at idv step', :phone_otp_delivery_selection
    it_behaves_like 'cancel at idv step', :phone_otp_delivery_selection, :oidc
    it_behaves_like 'cancel at idv step', :phone_otp_delivery_selection, :saml
  end
end
