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
  test_dir do
    (puts (run "#{t} >| test_result.txt || #{t}"))
    (puts (run '../bin/quickspec test.rb'))
    (puts (run '../bin/quickspec __test.rb --quicktest __test'))
  end
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
require 'quicktest.gemspec.rb'

Rake::GemPackageTask.new($gem_specification) do |pkg|
  pkg.need_tar = false
end

desc "generate the gem specification"
task :gem_specification do
  File.open('quicktest.gemspec', 'w') do |fh|
    fh.puts $gem_specification.to_ruby
  end
end
