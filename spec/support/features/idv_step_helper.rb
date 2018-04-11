module IdvStepHelper
  def self.included(base)
    base.class_eval { include IdvHelper }
  end

  def start_idv_at_profile_step(user = user_with_2fa)
    visit_idp_from_sp_with_loa3(:oidc)
    sign_in_live_with_2fa(user)
    click_idv_begin
  end

  def complete_idv_steps_before_address_step(user = user_with_2fa)
    start_idv_at_profile_step(user)
    fill_out_idv_form_ok
    click_idv_continue
  end

  def complete_idv_steps_before_phone_step(user = user_with_2fa)
    complete_idv_steps_before_address_step(user)
    click_idv_address_choose_phone
  end
end
