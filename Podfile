# Add CocoaPods spec sources (Arex first, then the master repo)
source 'https://github.com/a2/arex-pods.git'
source 'https://github.com/CocoaPods/Specs.git'

# Set the deployment target to iOS 8.0
platform :ios, '8.0'

# Use embedded frameworks
use_frameworks!

# Inhibit warnings
inhibit_all_warnings!

target 'Arex', exclusive: true do
  pod 'ArexKit', path: '.'
  pod 'SAMTextView', '~> 0.2.2'
end

target 'ArexTests' do
  pod 'ArexKit', path: '.'
  pod 'Nimble', '~> 0.4.0'
  pod 'Quick', '~> 0.3.0'
end
