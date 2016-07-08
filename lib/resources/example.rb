class Example < Toygun::Resource
  def_task :echo do
    state "one" do
      puts "one"
      transition "two"
    end
    state "two" do
      puts "two"
      stop
    end
  end
end
