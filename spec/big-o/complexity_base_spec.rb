require 'spec_helper'
include BigO

describe ComplexityBase do
  before :all do
    class FunctionComplexity
      include ComplexityBase
      def measure(*args, &b)
        1
      end
    end
  end

  context 'with default values' do
    before :each do
      @fn_complexity = FunctionComplexity.new
    end

    it 'should have a timeout of 10 seconds' do
      @fn_complexity.options[:timeout].should == 10
    end

    it 'should have no result defined' do
      @fn_complexity.result.should be_nil
    end

    it 'should have an approximation of 5%' do
      @fn_complexity.options[:approximation].should == 0.05
    end

    it 'should detect result set with less than 4 values' do
      @fn_complexity.result_set ||= {}
      3.times do |i|
        @fn_complexity.result_set[i] = i
      end
      @fn_complexity.small_result_set?.should be_true
      lambda { @fn_complexity.examine_result_set }.should raise_error(SmallResultSetError)
    end

    it 'should allow 5% of error in the results' do
      @fn_complexity.result_set ||= {}
      100.times do |i|
        @fn_complexity.result_set[i] = i
      end
      5.times do
        @fn_complexity.allow_inconsistency?.should be_true
      end
      @fn_complexity.allow_inconsistency?.should be_false
    end
  end

  context 'with overwritten values' do
    before :each do
      @fn_complexity = FunctionComplexity.new({ :timeout => 1,
                                                :approximation => 0.1 })
    end

    it 'should have the configured values' do
      @fn_complexity.options[:timeout].should == 1
      @fn_complexity.options[:approximation].should == 0.1
    end
  end

  describe 'before/after hooks' do
    before :each do
      @after_hook    = double('lambda')
      @before_hook   = double('lambda')
      @fn_complexity = FunctionComplexity.new({
          :fn          => lambda { |_| 1 },
          :level       => lambda { |_| 1},
          :before_hook => @before_hook,
          :after_hook  => @after_hook })
    end

    it 'should be called every time we try to match a complexity level' do
      @before_hook.should_receive(:call).with(kind_of(Integer)).at_most(20).times
      @after_hook.should_receive(:call).with(kind_of(Integer)).at_most(20).times
      @fn_complexity.process
    end
  end
end