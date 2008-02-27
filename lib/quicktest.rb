# :main: README

module QuickTest

  # create module variables
  class << self
    # don't record the fact that we add Module.method_added
    attr_accessor :ignore_first_method_added

    # set which code will be running the tests
    attr_accessor :runner, :runner_module
  end

  # to reuse this implementation
  # - create a module specific to the testing system
  # - and then add a flag at the bottom of this file to
  #   set QuickTest.runner_module to the new module
  # The module should
  # - implement any methods to be publicly available in the quicktest method
  # - contain the constants
  #   * QuickTestIgnoreClasses
  #   * QuickTestIncludeModules
  #
  # see RSpecTestRunner as an example
  #
  # it is possible to write a test runner without re-using this code.
  # The test runner class to be used is set at the bottom of this file
  # with QuickTest.runner = 
  class TestRunner
    class << self
      attr_accessor :methods, :tested_self
    end

    # keep a list of all traced methods
    self.methods = []
    def self.add_method( meth )
      self.methods.push meth
    end
    def self.add_singleton_method( meth )
      self.methods.push meth
    end

    def initialize tested
      self.class.tested_self = tested

      q = tested.method(:quicktest)
      tested.extend(QuickTest.runner_module)
      QuickTest.runner_module::QuickTestIncludeModules.each do |mod|
        tested.extend mod
      end
      
      case q.arity
      when 0 then q.call
      when 1 then q.call tested.method(self.class.methods[-1])
      else raise ArgumentError, "to many arguments for quicktest method"
      end

      tested.send :__quicktest_run_tests__
    end
  end

  # all public instance methods are RSpec method wrappers
  module RSpecTestRunner
    QuickTestIgnoreClasses = [/^Spec/]
    QuickTestIncludeModules = [Spec::Matchers]
    @@quicktests = Hash.new
    @@after_block = nil
    @@before_block = nil

    def before( &block ); @@before_block = block end
    def after( &block );  @@after_block = block end
    def it(specification, &block )
      @@quicktests[(TestRunner.methods.pop.to_s << ' ' << specification)] = block
      TestRunner.methods.clear
    end

  private
    def __quicktest_run_tests__ # :nodoc:
      before_block, after_block = @@before_block, @@after_block
      tests = @@quicktests

      describe( TestRunner.tested_self.to_s ) do
        before { before_block.call } if before_block
        after  { after_block.call } if after_block

        tests.each_pair do |spec, test_block|
          it( spec ) { test_block.call }
        end
      end
      @@quicktests.clear
      @@after_block  &&= nil
      @@before_block &&= nil
    end
  end

  # if the class under test (or one of its ancestors)
  # is overriding method tracing then it must include QuickTest::Tracer
  module Tracer
    def self.included(into)
      if into == Class or into == Module # default include in in Module
        self.tracer_include(into)
      else
        self.tracer_include((class<<into;self;end))
      end
    end

    def self.tracer_include(meta)
      meta.module_eval do

        # monkeypatch the two hook methods called on method creation
        # so they will still be called for any method other than _quicktest_
        alias_method :__quicktest_singleton_method_added__, :singleton_method_added
        alias_method :__quicktest_method_added__, :method_added

        # ruby tracing hook
        def singleton_method_added(traced)
          # avoid infinite recursion if module is included into a class by a user
          return if traced == QuickTest.runner.methods.last

          if traced == :quicktest
            QuickTest.runner.new self
          else
            QuickTest.runner.add_singleton_method traced
            __quicktest_singleton_method_added__ traced
          end
        end

        QuickTest.ignore_first_method_added = true

        # ruby tracing hook
        def method_added(traced)
          qt = QuickTest
          # avoid infinite recursion if module is included into a class by a user
          return if traced == qt.runner.methods.last

          if traced == :quicktest
            if self.class == Module
              fail "to test module instance methods, include them in a class"
            end
            qt.runner.new self.new

          else
            unless qt.ignore_first_method_added or
              qt.runner_module::QuickTestIgnoreClasses.detect {|m| self.to_s =~ m}
                qt.runner.add_method traced
            end

            qt.ignore_first_method_added = false
            __quicktest_method_added__ traced
          end
        end
      end
    end
  end
end


# add cases for different test handlers here
QuickTest.runner = QuickTest::TestRunner
QuickTest.runner_module = 
case ARGV[0]
when '--rspec' then ARGV.shift; QuickTest::RSpecTestRunner
else # assume rspec
  QuickTest::RSpecTestRunner
end

class Module # :nodoc:
  include QuickTest::Tracer
end
#class Class;  include QuickTest::Tracer end
