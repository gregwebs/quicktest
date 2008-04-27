$project = 'quicktest'
require 'tasks/helpers'

def test_dir; Dir.chdir('spec') {|dir| yield dir } end

class String
  def split_join( splitter=$/ )
    yield( split( splitter ) ).join( splitter )
  end
end

desc "test"
task :test do
  t = 'spec -r ../lib/quicktest test.rb'
  test_dir {(puts (run "#{t} >| test_result.txt || #{t}"))}
  test_dir { puts `../bin/quickspec __test.rb --quicktest __test` }
end

namespace :test do
  run = '../bin/quickspec test.rb'
  task :generate do
    test_dir {run "#{run} >| test_result.txt"}
  end

  desc "test quickspec executable"
  task :quickspec => :generate do
    test_dir {(puts (run "#{run}"))}
  end

  desc "test readme file"
  task :readme do
    (puts (run "./bin/quickspec README"))
  end
end

def decode_readme &block
  fail unless block_given?
  begin
    old_readme = nil
    File.read_write( 'README' ) do |text|
      old_readme = text
      text.split_join do |arr|
        arr.reject {|l| l =~ /^=(?:begin|end)/}
      end
    end
    block.call
  ensure
    File.write( 'README', old_readme ) if old_readme
  end
end

desc "generate documentation"
task :rdoc do
  decode_readme do
    fail unless system 'rdoc --force-update --quiet README lib/*'
  end
end

namespace :readme do
  desc "dump modified README"
  task :decode do
    decode_readme do
      puts File.read('README')
    end
  end

  desc "create html for website using coderay, use --silent option"
  task :html do
    rm_rf 'doc'
    decode_readme do
      fail unless system 'rdoc --force-update --quiet README'
    end
    require 'hpricot'
    require 'htmlentities'
    doc = open( 'doc/files/README.html' ) { |f| Hpricot(f) }
    # find example code
    doc.at('#description').search('pre').
      select {|elem| elem.inner_html =~ /class |module /}.each do |ex|
      # add coderay and undo what rdoc has done in the example code
      ex.swap("<coderay lang='ruby'>#{HTMLEntities.new.decode ex.inner_html}</coderay>")
    end
    puts doc.at('#description').to_html
  end
end

require 'rubygems'
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s|
  s.name = $project
  s.rubyforge_project = $project
  s.version = "0.5.6"
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

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = false
end
