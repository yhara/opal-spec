module OpalSpec
  class Example

    def self.groups
      @groups ||= []
    end

    def self.inherited klass
      Example.groups << klass
      klass.instance_eval { @before_hooks = []; @after_hooks = [] }
    end

    def self.stack
      @stack ||= []
    end

    def self.create(desc, block)
      parent = Example.stack.last

      Class.new(parent || Example) do
        @desc   = desc
        @parent = parent
      end
    end

    def self.to_s
      "<OpalTest::Spec #{@desc.inspect}>"
    end

    def self.description
      @parent ? "#{@parent.description} #{@desc}" : @desc
    end

    def self.it(desc, &block)
      @examples ||= []
      @examples << [desc, block]
    end

    def self.async(desc, &block)
      self.it desc do
        self.async!
        instance_eval(&block)
      end
    end

    def self.pending(desc, &block)
      @pending ||= []
      @pending << [desc, block]
    end

    def self.let(name, &block)
      define_method(name) do
        @_memoized ||= {}
        @_memoized.fetch(name) { |n| @_memoized[n] = instance_eval(&block) }
      end
    end

    def self.subject(&block)
      let(:subject, &block)
    end

    # type is ignored (is always :each)
    def self.before(type = nil, &block)
      @before_hooks << block
    end

    # type is ignored (is always :each)
    def self.after(type = nil, &block)
      @after_hooks << block
    end

    def self.run runner
      @runner = runner
      @runner.example_group_started self

      @running_examples = @examples ? @examples.dup : []
      run_next_example
    end

    def self.run_next_example
      if @running_examples.empty?
        @runner.example_group_finished self
      else
        new(@running_examples.shift).run @runner
      end
    end

    def self.example_started example
      @runner.example_started example
    end

    def self.example_passed example
      @runner.example_passed example
      run_next_example
    end

    def self.example_failed example
      @runner.example_failed example
      run_next_example
    end

    def self.after_hooks
      @parent ? @parent.after_hooks + @after_hooks : @after_hooks
    end

    def self.before_hooks
      @parent ? @parent.before_hooks + @before_hooks : @before_hooks
    end

    attr_reader :example_group, :exception

    def initialize info
      @description = info[0]
      @__block__ = info[1]
      @example_group = self.class
    end

    def description
      @description
    end

    def async!
      @asynchronous = true
    end

    def run runner
      @runner = runner
      begin
        @example_group.example_started self
        run_before_hooks
        instance_eval(&@__block__)
      rescue => e
        @exception = e
      ensure
        unless @asynchronous
          run_after_hooks
        end
      end

      if @asynchronous
        # must wait..
      else
        finish_running
      end
    end

    def finish_running
      if @exception
        @example_group.example_failed self
      else
        @example_group.example_passed self
      end
    end

    def run_before_hooks
      @example_group.before_hooks.each do |before|
        instance_eval(&before)
      end
    end

    def run_after_hooks
      begin
        @example_group.after_hooks.each do |after|
          instance_eval(&after)
        end
      rescue => e
        @exception = e
      end
    end

    def run_async(&block)
      begin
        block.call
      rescue => e
        @exception = e
      ensure
        run_after_hooks
      end

      finish_running
    end

    def set_timeout(duration, &block)
      `setTimeout(#{block}, #{duration})`
      self
    end
  end
end