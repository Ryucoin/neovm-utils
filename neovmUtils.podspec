Pod::Spec.new do |s|
  s.name             = 'neovmUtils'
  s.version          = '1.5.9'
  s.summary          = 'Swift SDK for the Ontology and NEO blockchains'

  s.homepage         = 'https://github.com/Ryucoin/neovm-utils'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'WyattMufson' => 'wyatt@towerbuilders.org' }
  s.source           = { :git => 'https://github.com/Ryucoin/neovm-utils.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'
  s.swift_version = '5.1'

  s.source_files = 'neovmUtils/Classes/**/*'
  s.vendored_frameworks = 'neoutils.framework'
  s.dependency 'RyuCrypto', '0.0.1'
  s.dependency 'Socket.IO-Client-Swift', '14.0.0'
  s.dependency 'NetworkUtils', '1.0.0'
end
