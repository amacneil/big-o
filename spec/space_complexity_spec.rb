require 'spec_helper'
include Complexity

describe SpaceComplexity do
  before :each do
    @space_complexity = SpaceComplexity.new
  end

  it 'should raise an exception if timeout is reached and no result was found' do
    @space_complexity.timeout = 0.001
    @space_complexity.fn      = lambda { |_| simulate_memory_space(1) }
    lambda { @space_complexity.process }.should raise_error(Timeout::Error)
  end

  describe '#process on complexity O(1)' do
    before :each do
      @space_complexity.fn    = lambda { |_| simulate_memory_space(1024) }
    end

    it 'should run the function and produce a report when time threshold is hit' do
      @space_complexity.approximation = 0.20
      @space_complexity.should match_complexity_level 'O(1)', lambda { |_| 1 }
    end
  end

  describe '#process on complexity O(n)' do
    before :each do
      @space_complexity.fn    = lambda { |n| simulate_memory_space(1024 * n) }
    end

    it 'should run the function and produce a report when time threshold is hit' do
      @space_complexity.should match_complexity_level 'O(n)', lambda { |n| n }
    end
  end

  describe '#process on complexity O(n**2)' do
    before :each do
      @space_complexity.fn    = lambda { |n| simulate_memory_space(1024 * n**2) }
    end

    it 'should run the function and produce a report when time threshold is hit' do
      @space_complexity.should match_complexity_level 'O(n^2)', lambda { |n| n**2 }
    end

    it 'should return false if the complexity does not match (too low)' do
      @space_complexity.approximation = 0.2
      @space_complexity.should_not match_complexity_level 'O(1)', lambda { |_| 1 }
    end
  end

  describe 'very small memory usage' do
    it 'should throw an error when memory can\'t be measured'
  end
end