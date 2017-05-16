module Users
  class VerifyAccountController < ApplicationController
    before_action :confirm_two_factor_authenticated
    before_action :confirm_verification_needed

    def index
      @verify_account_form = VerifyAccountForm.new(user: current_user)
    end

    def create
      @verify_account_form = build_verify_account_form
      if @verify_account_form.submit
        flash[:success] = t('account.index.verification.success')
        redirect_to after_sign_in_path_for(current_user)
      else
        render :index
      end
    end

    private

    def build_verify_account_form
      VerifyAccountForm.new(
        user: current_user,
        otp: params_otp,
        pii_attributes: decrypted_pii
      )
    end

    def params_otp
      params[:verify_account_form].permit(:otp)[:otp]
    end

    def confirm_verification_needed
      return if current_user.decorate.pending_profile_requires_verification?
      redirect_to account_url
    end

    def decrypted_pii
      @_decrypted_pii ||= begin
        cacher = Pii::Cacher.new(current_user, user_session)
        cacher.fetch
      end
    end
  end
end