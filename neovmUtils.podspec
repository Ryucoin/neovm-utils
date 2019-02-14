#
# Be sure to run `pod lib lint neovmUtils.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'neovmUtils'
  s.version          = '0.1.8'
  s.summary          = 'Useful functions for the NEO and Ontology blockchains for iOS.'

  s.homepage         = 'https://github.com/Ryucoin/neovm-utils'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'WyattMufson' => 'wyatt@ryucoin.com' }
  s.source           = { :git => 'https://github.com/Ryucoin/neovm-utils.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'
  s.swift_version = '4.2'

  s.source_files = 'neovmUtils/Classes/**/*'
  s.vendored_frameworks = 'neoutils.framework'
  s.source_files = 'TrezorCrypto/*.{c,h}'
  s.public_header_files = 'TrezorCrypto/*.h'
  s.pod_target_xcconfig = {'SWIFT_INCLUDE_PATHS' => '$(SRCROOT)/TrezorCrypto/**','LIBRARY_SEARCH_PATHS' => '$(SRCROOT)/TrezorCrypto'}
  s.preserve_paths  = 'TrezorCrypto/module.modulemap'

end
