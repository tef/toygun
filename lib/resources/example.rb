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
end
