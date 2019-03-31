Pod::Spec.new do |s|
  s.name             = 'neovmUtils'
  s.version          = '0.4.2'
  s.summary          = 'Swift SDK for the NEO and Ontology blockchains'

  s.homepage         = 'https://github.com/Ryucoin/neovm-utils'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'WyattMufson' => 'wyatt@ryucoin.com' }
  s.source           = { :git => 'https://github.com/Ryucoin/neovm-utils.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'
  s.swift_version = '5'

  s.source_files = 'neovmUtils/Classes/**/*'
  s.vendored_frameworks = 'neoutils.framework'
  s.dependency 'RyuCrypto', '~> 0.0.1'

end
