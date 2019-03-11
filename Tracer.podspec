Pod::Spec.new do |s|
    s.name             = 'Tracer'
    s.version          = '1.0'
    s.summary          = 'Custom Xcode Instruments package that implements tracing of any activities inside the app'
    s.homepage         = 'http://appspector.com'
    s.license          = { type: 'MIT', file: 'LICENSE' }
    s.author           = { 'Techery' => 'heroes@techery.io' }
    s.source           = { :git => 'https://github.com/appspector/Tracer.git', :tag => '1.0.1' }
    
    s.ios.deployment_target  = '9.0'
    s.osx.deployment_target  = '10.11'    
    s.source_files           = 'Tracer/TracingModule/*'
end
