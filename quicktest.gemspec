Gem::Specification.new do |s|
  s.name = %q{quicktest}
  s.version = "0.6.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Greg Weber"]
  s.date = %q{2008-11-06}
  s.default_executable = %q{quickspec}
  s.executables = ["quickspec"]
  s.extra_rdoc_files = ["README"]
  s.files = ["./bin", "./doc", "./lib", "./TODO", "./spec", "./quicktest.gemspec.rb", "./Rakefile", "./tasks", "./README", "./quicktest-0.6.1.gem", "bin/quickspec", "doc/files", "doc/index.html", "doc/rdoc-style.css", "doc/fr_method_index.html", "doc/fr_class_index.html", "doc/fr_file_index.html", "doc/created.rid", "doc/classes", "lib/quicktest.rb", "spec/__test.rb", "spec/test.rb", "tasks/helpers.rb", "tasks/gregproject.rake", "README"]
  s.has_rdoc = true
  s.homepage = %q{http://gregweber.info/projects/quicktest.html}
  s.post_install_message = %q{
  spec and quickspec are ruby executable scripts, whose directory location must be in your PATH environment variable (or you must invoke the with the full file path).

  run tests with
     quickspec [file1 file2 ...]

}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{quicktest}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{utility for inlining tests with the code tested}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_runtime_dependency(%q<rspec>, [">= 1.0.0"])
    else
      s.add_dependency(%q<rspec>, [">= 1.0.0"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 1.0.0"])
  end
end
