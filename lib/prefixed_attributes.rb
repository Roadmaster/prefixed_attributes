# PrefixedAttributes
#


module PrefixedAttributes#:nodoc:

  PREFIXES_SI={
    "deca"  => 10**1,
    "hecto" => 10**2,
    "kilo"  => 10**3,
    "mega"  => 10**6,
    "giga"  => 10**9,
    "tera"  => 10**12,
    "peta"  => 10**15,
    "exa"   => 10**18,
    "zetta"   => 10**21,
    "yotta"   => 10**24,
    "deci"  => 1.0/(10**1),
    "centi" => 1.0/(10**2),
    "mili"  => 1.0/(10**3),
    "milli" => 1.0/(10**3),
    "micro" => 1.0/(10**6),
    "nano"  => 1.0/(10**9),
    "pico"  => 1.0/(10**12),
    "femto"  => 1.0/(10**12),
    "atto"  => 1.0/(10**15),
    "zepto"  => 1.0/(10**18),
    "yocto"  => 1.0/(10**21)
  }

  PREFIXES_BINARY={
    "kibi" => 1024**1,
    "mebi" => 1024**2,
    "gibi" => 1024**3,
    "tebi" => 1024**4,
    "pebi" => 1024**5,
    "exbi" => 1024**6,
    "zebi" => 1024**7,
    "yobi" => 1024**8
  }

  PREFIXES={:si => PREFIXES_SI, :binary => PREFIXES_BINARY}

  #I have no idea how this works
  def self.append_features(base) #:nodoc:
    super
    base.extend(ClassMethods)

  end

  module ClassMethods#:nodoc:


    #declares an attribute as prefixed, and will add scalable getter and
    #setter methods according to which :type is specified, either :si or :binary.
    def prefixed_attribute(attr_name,options={:type => :binary})
      return nil unless attr_name &&  !attr_name.to_s.empty?
      return nil unless  options.has_key?(:type) && PREFIXES.has_key?(options[:type])
      attr_name=attr_name.to_s

      prefixes=PREFIXES[options[:type]] if PREFIXES[options[:type]]

      prefixes.each do |prefix,divisor|
        method_name = prefix+attr_name
        #we define a setter and a getter, both virtual attributes
        define_method method_name do
          (self.send(attr_name)||0) / divisor.to_f
        end

        define_method "#{method_name}=" do |new_value|
          self.send "#{attr_name}=".to_sym,   new_value.to_f * divisor if new_value
        end
      end

    end

  end
end
