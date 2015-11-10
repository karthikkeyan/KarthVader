Pod::Spec.new do |spec|

  spec.name         = 'KarthVader'
  spec.version      = '1.0'
  spec.license      = { :type => 'MIT' }
  spec.homepage     = 'https://github.com/karthikkeyan/KarthVader'
  spec.authors      = { 'Karthik Keyan' => 'karthikkeyan.balan@gmail.com' }
  spec.summary      = 'A simple and easy to use wrapper for core data'
  spec.source       = { :git => 'https://github.com/karthikkeyan/KarthVader.git', :tag => spec.version }
  spec.source_files = '*.swift'
  spec.framework    = 'CoreData'

  spec.ios.deployment_target = '9.0'
  spec.osx.deployment_target = '10.10'

end
