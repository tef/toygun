class Example < Toygun::Resource
  field :nice

  def_task :echo do
    field  :something

    state "one" do
      puts "one"
      self.something = [1,2,3]
      transition "two"
    end
    state "two" do
      puts "two #{something}" 
      stop
    end
  end

  def_task :another do
    field :time
    field :echo

    state "one" do
      self.time = Time.now
      transition "two"
    end

    state "two" do
      puts "was #{time}"
      self.echo = parent.echo
      transition "three"
    end

    state "three" do
      puts "other task #{echo}"
      stop
    end
  end
end
