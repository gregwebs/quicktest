# regenerate test_result.txt with
# spec -r ../lib/quicktest test.rb >| test_result.txt
# run tests with
# spec -r ../lib/quicktest test.rb
# regenerate and run
# spec -r ../lib/quicktest test.rb >| test_result.txt || spec -r ../lib/quicktest test.rb

# all tests for this class should always pass
class Tester
  def self.meth
    "hello"
  end
  def self.quicktest
    it "should say hi" do
      meth.should == "hello"
      lambda{raise}.should raise_error
    end
  end
  def self.hello arg
    "hello" + arg
  end
  def self.quicktest m
    it "should say hello" do
      m[' bob'].should == "hello bob"
    end
  end
  def method_missing meth
    @foo if meth == :foo
  end
  def initialize
    @foo = true
  end
  def quicktest
    it "foo should be true" do
      foo.should == true
    end
  end
  def bar; @foo end
  def quicktest meth
    it "foo should be true" do
      meth.call.should == true
    end
  end
end

# test failure text
$r = File.readlines('test_result.txt')
3.times {$r.shift}

def quicktest
  msg = "should show class name in output"
  it msg do
    $r.shift.should =~ /^'#<#{self.class}:0x[^>]+>  #{msg}' FAILED$/
    7.times {$r.shift}
  end
end
@@new_meth = :new_method_added
eval"def #@@new_meth; end"

def quicktest
  msg = "should show name of added method"
  it msg do
    $r.shift.should =~ /^'#<#{self.class}:0x[^>]+> #{@@new_meth} #{msg}' FAILED$/
    7.times {$r.shift}
  end
end

module TestModule
  @@klass = self
  def self.quicktest
    msg = "should show class name in output"
    it msg do
      $r.shift.should =~ /^'#{@@klass}  #{msg}' FAILED$/
      7.times {$r.shift}
    end
  end

  @@new_singleton_meth = 'new_singleton_method_added'
  eval"def self.#@@new_singleton_meth;end"

  def self.quicktest
    msg = "should show class name in output"
    it msg do
      $r.shift.should =~ /^'#{@@klass} #@@new_singleton_meth #{msg}' FAILED$/
      7.times {$r.shift}
    end
  end
end

class TestClass
  @@klass = self
  def self.quicktest
    msg = "should show class name in output"
    it msg do
      $r.shift.should =~ /^'#{@@klass}  #{msg}' FAILED$/
      7.times {$r.shift}
    end
  end
  def quicktest
    msg = "should show class name in output"
    it msg do
      $r.shift.should =~ /^'#<#{self.class}:0x[^>]+>  #{msg}' FAILED$/
      7.times {$r.shift}
    end
  end
  @@new_meth = :new_method_added
  define_method @@new_meth do end

  def quicktest
    msg = "should show name of added method"
    it msg do
      $r.shift.should =~ /^'#<#{self.class}:0x[^>]+> #{@@new_meth} #{msg}' FAILED$/
      7.times {$r.shift}
    end
  end

  @@new_singleton_meth = 'new_singleton_method_added'
  eval"def self.#@@new_singleton_meth;end"

  def self.quicktest
    msg = "should show class name in output"
    it msg do
      $r.shift.should =~ /^'#{@@klass} #@@new_singleton_meth #{msg}' FAILED$/
      7.times {$r.shift}
    end
  end
end
