#
# Be sure to run `pod lib lint neovmUtils.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'neovmUtils'
  s.version          = '0.1.0'
  s.summary          = 'Useful functions for the NEO and Ontology blockchains for iOS.'

  s.homepage         = 'https://github.com/Ryucoin/neovmUtils'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'WyattMufson' => 'wyatt@ryucoin.com' }
  s.source           = { :git => 'https://github.com/Ryucoin/neovmUtils.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'neovmUtils/**/*/*.swift'
  s.vendored_frameworks = 'Example/neoutils.framework'

end
