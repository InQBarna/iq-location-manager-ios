Pod::Spec.new do |s|
  s.name         = "IQLocationManager"
  s.version      = "0.0.4"
  s.summary      = "Helper for getting user's device location"
  s.homepage     = "http://gitlab.inqbarna.com/internal/iq-location-manager-ios"
  s.author       = { "Nacho Sanchez" => "nacho.sanchez@inqbarna.com", "Héctor Marqués" => "hector.marques@inqbarna.com"  }
  s.license      = 'commercial'

  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.7'

  s.source       = { :git => "http://gitlab.inqbarna.com/internal/iq-location-manager-ios.git", :tag => "0.0.4" }
  s.source_files = 'IQLocationManager/*.{h,m}'

  s.framework  = 'CoreLocation'

  s.requires_arc = true

end
