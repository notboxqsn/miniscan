Pod::Spec.new do |s|
  s.name           = 'DocumentDetection'
  s.version        = '1.0.0'
  s.summary        = 'Document edge detection using Apple Vision framework'
  s.description    = 'Expo module for detecting document boundaries in images using VNDetectDocumentSegmentationRequest'
  s.homepage       = 'https://github.com/placeholder'
  s.license        = 'MIT'
  s.author         = 'Dev'
  s.platform       = :ios, '15.0'
  s.source         = { git: '' }
  s.source_files   = '**/*.swift'
  s.frameworks     = 'Vision'

  s.dependency 'ExpoModulesCore'
end
