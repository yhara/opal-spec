describe "PositiveOperatorMatcher" do
  it "matches should operators" do
    1.should == 1
  end

  it "matches negative operators" do
    1.should_not == 2
  end
end

describe 'Normal group' do
  it 'exceptions can be thrown' do
    err = nil

    begin
      1.should == 2
    rescue Exception => e
      err = e
    end

    raise "exception not thrown" unless err
  end
end

describe "New eql" do
  it "these should both pass" do
    1.should eq(1)
    1.should_not eq(2)
  end

  it "and this should fail" do
    lambda { 1.should eq(:adam) }.should raise_error(Exception)
  end
end

describe Object do
  it "should output a nice name for classes" do
    1.should eq(1)
  end
end

describe 'Another group' do
  it 'this should pass' do
    1.should == 1
  end

  it 'this should pass' do
    true.should be_true
    false.should be_false
    nil.should be_nil
  end

  async 'this should pass (in 0.1 second time)' do
    set_timeout(100) do
      run_async {
        1.should == 1
      }
    end
  end

  async 'this should fail (in 0.1 second time)' do
    set_timeout(100) do
      run_async {
        lambda { 1.should == 5 }.should raise_error(Exception)
      }
    end
  end
end

describe "let" do
  $opal_spec_let_count = 0

  let(:count) { $opal_spec_let_count = $opal_spec_let_count + 1 }

  it "caches the method for the example" do
    count.should eq(1)
    count.should eq(1)
  end

  it "does not cache values between different examples" do
    count.should eq(2)
  end
end

describe "before" do
  before do
    @foo = 100
  end

  before do
    @bar = 200
  end

  it "should be run before each group" do
    @foo.should == 100
  end

  it "should run multiple before blocks" do
    @bar.should == 200
  end

  describe "nested" do
    before { @nested = 300 }

    it "should inherit before blocks" do
      @foo.should eq(100)
    end

    it "should also run nested before blocks" do
      @nested.should eq(300)
    end
  end
end

describe "pending" do
  pending "these tests are not run" do
    raise "otherwise this error would be raised"
  end
end

describe "A nested group" do
  describe "inherits group names" do
    it "examples should pass" do
      1.should eq(1)
    end
  end
end

OpalSpec.matcher :custom_matcher do
  def match expected
    unless expected == 42
      failure "foo"
    end
  end
end

describe "Custom Matchers" do
  it "is defined in spec scope" do
    respond_to?(:custom_matcher).should be_true
  end

  it "passes the expected value to the matcher" do
    42.should custom_matcher
  end

  it "can raise error when not maching expectation" do
    lambda { 43.should custom_matcher }.should raise_error(Exception)
  end
end if false
