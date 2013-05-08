module OpalSpec
  class BeEmptyMatcher < Matcher
    def match(actual)
      unless actual.empty?
        failure "Expected #{actual.inspect} to be empty"
      end
    end
  end
end

class Object
  def be_empty
    OpalSpec::BeEmptyMatcher.new
  end
end