module IdvStepHelper
  def self.included(base)
    base.class_eval { include IdvHelper }
  end

  def start_idv_from_sp(sp = :oidc)
    if sp.present?
      visit_idp_from_sp_with_loa3(sp)
      click_link t('links.sign_in')
    else
      visit root_path
    end
  end

  def complete_idv_steps_before_verify_step(user = user_with_2fa)
    sign_in_and_2fa_user(user)
    visit verify_path unless current_path == verify_path
  end

  def complete_idv_steps_before_profile_step(user = user_with_2fa)
    complete_idv_steps_before_verify_step(user)
    click_idv_begin
  end

  def complete_idv_steps_before_address_step(user = user_with_2fa)
    complete_idv_steps_before_profile_step(user)
    fill_out_idv_form_ok
    click_idv_continue
  end

  def complete_idv_steps_before_phone_step(user = user_with_2fa)
    complete_idv_steps_before_address_step(user)
    click_idv_address_choose_phone
  end

  def complete_idv_steps_before_usps_step(user = user_with_2fa)
    complete_idv_steps_before_address_step(user)
    click_idv_address_choose_usps
  end

  def complete_idv_steps_before_phone_otp_delivery_selection_step(user = user_with_2fa)
    complete_idv_steps_before_phone_step(user)
    fill_out_phone_form_ok('2341230638')
    click_idv_continue
  end

  def complete_idv_steps_before_phone_otp_verification_step(user = user_with_2fa)
    complete_idv_steps_before_phone_otp_delivery_selection_step(user)
    choose_idv_otp_delivery_method_sms
  end

  def complete_idv_steps_before_review_step(user = user_with_2fa)
    complete_idv_steps_before_phone_step(user)
    fill_out_phone_form_ok(user.phone)
    click_idv_continue
  end

  def complete_idv_steps_before_confirmation_step(user = user_with_2fa)
    complete_idv_steps_before_review_step(user)
    fill_in 'Password', with: password
    click_continue
  end

  def complete_idv_steps_before_step(step, user = user_with_2fa)
    send("complete_idv_steps_before_#{step}_step", user)
  end
end
