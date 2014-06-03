Pod::Spec.new do |s|
  s.name     = 'BZGMailgunEmailValidation'
  s.version  = '1.1.1'
  s.license  = 'MIT'
  s.summary  = 'A simple wrapper for the Mailgun email validation API.'
  s.homepage = 'https://github.com/benzguo/BZGMailgunEmailValidation'
  s.author   = { 'Ben Guo' => 'benzguo@gmail.com' }
  s.source   = { :git => 'https://github.com/benzguo/BZGMailgunEmailValidation.git', :tag => s.version }
  s.platform = :ios, "3.0"
  s.source_files = 'BZGMailgunEmailValidator.{h,m}'
  s.requires_arc = true
end
