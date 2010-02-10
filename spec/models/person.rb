# Non-active record model to test
class Person
  attr_accessor :name, :age

  def initialize(attr)
    @name, @age = attr[:name], attr[:age]
  end

  def ==(other)
    other.is_a?(Person) && other.name == name && other.age == age
  end
end
