require 'test/unit'

require File.dirname(__FILE__) + '/../lib/prefixed_attributes'


class PrefixedAttributesTest < Test::Unit::TestCase

  include  PrefixedAttributes

  def setup
    @binary = Class.new
    @metric = Class.new
    @blank_binary = Class.new

    @binary.class_eval do 
      include PrefixedAttributes
      attr :bytes, true
      prefixed_attribute :bytes, :type => :binary
    end

    @metric.class_eval do 
      include PrefixedAttributes
      attr :hertz, true

      prefixed_attribute :hertz, :type => :si
    end

    #some tests need a class with no prefixed_attributes declared.
    @blank_binary.class_eval do 
      include PrefixedAttributes
      attr :bytes, true
    end

    @binary_object = @binary.new
    @metric_object = @metric.new
  end

  #If no type specified, default to binary
  def test_should_be_binary_if_no_type_specified
    @blank_binary.class_eval do
      prefixed_attribute :bytes
    end

    temp_binary_object = @blank_binary.new

    temp_binary_object.bytes = 1024
    assert_respond_to temp_binary_object, :kibibytes
    assert_respond_to temp_binary_object, :kibibytes=
      assert_equal 1,temp_binary_object.kibibytes

  end


  #HOWEVER, if an invalid type is specified, do NOT add prefixed methods at
  #all.
  def test_should_ignore_invalid_type
    @blank_binary.class_eval do
      prefixed_attribute :bytes, :type => :unknown_invalid
    end

    temp_binary_object = @blank_binary.new

    temp_binary_object.bytes = 1024
    assert_raise NoMethodError do
      temp_binary_object.kibibytes
    end
    assert_raise NoMethodError do
      temp_binary_object.kilobytes
    end
  end


  def test_should_not_error_with_invalid_parameters
    #Object should initialize correctly even if parameters to
    #prefixed_attribute are a mess
    @temp_binary_object=nil
    assert_nothing_raised do 
      @blank_binary.class_eval do
        prefixed_attribute :bytels, :atype => :unknown_invalid
      end
      @temp_binary_object = @blank_binary.new
    end
    #BUT, no methods should be added to the object if params to
    #prefixed_attribute are invalid.
    assert_raise NoMethodError do
      @temp_binary_object.kibibytels
    end
    assert_raise NoMethodError do
      @temp_binary_object.kilobytels
    end
  end

  def test_should_not_prefix_inexistent_attribute
    @blank_binary.class_eval do
      prefixed_attribute :bytles, :type => :si
    end
    temp_binary_object = @blank_binary.new
    assert_raise NoMethodError do
      temp_binary_object.kilobytles
    end

  end


  #These tests check behavior of legitimately-created objects
  def test_set_binary
    @binary_object.bytes=1024

    assert_equal 1024,@binary_object.bytes
  end

  def test_set_metric
    @metric_object.hertz=1000000
    assert_equal 1000000,@metric_object.hertz
  end



  def test_should_return_1_mega
    @binary_object.bytes = 2**20 
    assert_equal 1,@binary_object.mebibytes

  end

  def test_should_set_attribute_through_virtual_for_mega
    @metric_object.megahertz=1
    assert_equal 1000000, @metric_object.hertz
  end

  def test_should_have_binary_equivalences

    @binary_object.gibibytes=16
    assert_equal 16384,@binary_object.mebibytes
    assert_equal 16777216, @binary_object.kibibytes
  end

  def test_should_have_metric_equivalences
    @metric_object.gigahertz=16
    assert_equal 16000,       @metric_object.megahertz
    assert_equal 16000000,    @metric_object.kilohertz
    assert_equal 16000000000, @metric_object.hertz
  end

  def test_should_return_zero_on_nil_attribute
    @binary_object.bytes=nil
    assert_equal 0, @binary_object.mebibytes
  end

  def test_should_have_metric_divisor_equivalences
    @metric_object.hertz = 1
    assert_equal 1000, @metric_object.milihertz
    assert_equal 1000000, @metric_object.microhertz
  end

  def test_should_set_attribute_through_virtual_for_micro
    @metric_object.microhertz = 5*10**6
    assert_equal 5, @metric_object.hertz
  end

  def test_should_not_do_crazy_stuff_with_numeric_string_arguments
    @metric_object.decahertz="20"
    assert_equal 200, @metric_object.hertz
  end

  def test_should_not_do_crazy_stuff_with_non_numeric_string_arguments
    @metric_object.decahertz="aeroplano"
    assert_equal 0, @metric_object.hertz
  end



end
