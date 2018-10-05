module WebauthnConfigurationsExtension
  # :reek:FeatureEnvy
  def selection_presenters
    proxy_association.load_target unless proxy_association.loaded?
    configuration = proxy_association.target.detect(&:mfa_enabled?)

    if configuration.present?
      configuration.selection_presenters
    else
      []
    end
  end
end
