$project = 'quicktest'
require 'rake'
Gem::Specification.new do |s|
  s.name = $project
  s.rubyforge_project = $project
  s.version = "0.6.1"
  s.author = "Greg Weber"
  s.email = "greg@gregweber.info"
  s.homepage = "http://quicktest.rubyfore.org/"
  s.platform = Gem::Platform::RUBY
  s.summary = "utility for inlining tests with the code tested"
  s.executables = ['quickspec']
  s.files = FileList.new('./**', '*/**') do |fl|
             fl.exclude('pkg','pkg/*','tmp','tmp/*')
           end
  s.require_path = "lib"
  s.has_rdoc = true
  s.extra_rdoc_files = ["README"]
  s.add_dependency('rspec', '>= 1.0.0')
  s.post_install_message = <<-EOS

  spec and quickspec are ruby executable scripts, whose directory location must be in your PATH environment variable (or you must invoke the with the full file path).

  run tests with
     quickspec [file1 file2 ...]

EOS
end
