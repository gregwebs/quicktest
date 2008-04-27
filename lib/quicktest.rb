# :main: README

# TODO
# allow self.quicktest after instance method, and quicktest after a class method
# test module instance methods by setting the quicktest object to include them into

module QuickTest

  # create module variables
  class << self
    # then name of the testing method, default is :quicktest
    attr_accessor :test_method

    # don't record the fact that we add Module.method_added
    attr_accessor :ignore_first_method_added

    # set which code will be running the tests
    attr_accessor :runner, :runner_module

    # when testing module instance methods
    # this defines the class to include a module into
    # user sets this by defining self.quicktest_include_into in a module
    # otherwise, a generic class is used
    attr_accessor :include_module_into

    attr_accessor :last_self
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
    def self.add_method meth
      self.methods.push meth
    end
    def self.add_singleton_method meth
      self.methods.push meth
    end

    def initialize tested
      self.class.tested_self = tested

      q = tested.method(QuickTest.test_method)
      tested.extend(QuickTest.runner_module)
      QuickTest.runner_module::QuickTestIncludeModules.each do |mod|
        tested.extend mod
      end
      
      case q.arity
      when 0 then q.call
      when 1 then q.call tested.method(self.class.methods[-1])
      else raise ArgumentError, "to many arguments for #{QuickTest.test_method} method"
      end

      tested.send :__quicktest_run_tests__

      # removing the quicktest method will prevent Ruby from warning about the method being redefined
      # I don't know how to remove a class method
      unless tested.kind_of?(Class) or tested.kind_of?(Module)
        tested.class.class_eval { remove_method QuickTest.test_method }
      end
    end
  end

  # all public instance methods are RSpec method wrappers
  module RSpecTestRunner
    QuickTestIgnoreClasses = [/^Spec/]
    QuickTestIncludeModules = [Spec::Matchers]
    @@quicktests = Hash.new
    @@after_block = nil
    @@before_block = nil

    def before( *args, &block ) @@before_block = [args, block] end
    def after(  *args, &block ) @@after_block  = [args, block] end
    def it specification, &block
      @@quicktests[(TestRunner.methods.pop.to_s << ' ' << specification)] = block
      TestRunner.methods.clear
    end

  private
    def __quicktest_run_tests__ # :nodoc:
      before_args, before_block = @@before_block
      after_args, after_block = @@after_block
      tests = @@quicktests

      describe( TestRunner.tested_self.to_s ) do
        before(*before_args) { before_block.call } if before_block
        after(*after_args)   { after_block.call }  if after_block

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
        self.tracer_include into
      else
        self.tracer_include(class<<into;self;end)
      end
    end

    def self.tracer_include(meta)
      meta.module_eval do

        # monkeypatch the two hook methods called on method creation
        # so they will still be called for any method other than _quicktest_
        alias_method :__quicktest_singleton_method_added__, :singleton_method_added
        alias_method :__quicktest_method_added__, :method_added

        # ruby tracing hook
        def singleton_method_added traced
          # avoid infinite recursion if module is included into a class by a user
          return if traced == QuickTest.runner.methods.last

          if QuickTest.last_self != self
            QuickTest.last_self = self
            QuickTest.include_module_into = nil
          end

          if traced == QuickTest.test_method
            QuickTest.runner.new self

          elsif traced == :quicktest_include_into
            QuickTest.include_module_into = self.quicktest_include_into

          else
            QuickTest.runner.add_singleton_method traced
            __quicktest_singleton_method_added__ traced
          end
        end

        QuickTest.ignore_first_method_added = true

        # ruby tracing hook
        def method_added traced
          qt = QuickTest
          # avoid infinite recursion if module is included into a class by a user
          return if traced == qt.runner.methods.last

          if traced == QuickTest.test_method
            qt.runner.new(
              if self.class != Module
                self.new
              else
                Class.new(QuickTest.include_module_into || Object).extend(self)
              end
            )

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


# configurable
QuickTest.test_method = :quicktest
QuickTest.runner = QuickTest::TestRunner
QuickTest.runner_module = QuickTest::RSpecTestRunner

files = []
while(arg = ARGV.shift)
  case arg
  when '--rspec'
    QuickTest.runner_module = ARGV.shift ||
      (puts "--rspec requires an argument";exit(1))
  when '--quicktest'
    QuickTest.test_method = ARGV.shift.to_sym ||
      (puts "--quicktest requires an argument";exit(1))
  else
    (puts "unknown argument: #{arg}";exit(1)) unless File.exist? arg
    files.push(arg)
  end
end
ARGV.concat files

# trace all methods
class Module # :nodoc:
  include QuickTest::Tracer
end

# TODO: run pending tests at exit
#at_exit do end
