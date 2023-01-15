# 

```python
class First():
    """要理解类的含义，我们必须理解内置的 __init__() 函数。 所有类都有一个名为 __init__() 的函数，它总是在类启动时执行。 
    使用 __init__() 函数为对象属性赋值，或者在创建对象时需要执行的其他操作
    每次使用该类创建新对象时，都会自动调用 __init__() 函数。
    """
    def __int__(self,name):
        self.name = name
        
    def __str__(self):
        return f"yes"

    def __len__(self):
        return 120


```


## __init__
```python
class First():
    """要理解类的含义，我们必须理解内置的 __init__() 函数。 所有类都有一个名为 __init__() 的函数，它总是在类启动时执行。 
    使用 __init__() 函数为对象属性赋值，或者在创建对象时需要执行的其他操作
    每次使用该类创建新对象时，都会自动调用 __init__() 函数。
    """
    def __int__(self,name):
        self.name = name
```
```python
class Person:
  def __init__(self, name, age):
    self.name = name
    self.age = age

p1 = Person("John", 36)

print(p1.name)
print(p1.age)
# John
# 36
```

## __str__
```python
"""
__str__() 函数控制当类对象表示为字符串时应返回的内容。 
如果未设置 __str__() 函数，则返回对象的字符串表示形式
"""
class Person:
  def __init__(self, name, age):
    self.name = name
    self.age = age

p1 = Person("John", 36)

print(p1)
# <__main__.Person object at 0x000001EA23A23450>
```
```python
class Person:
  def __init__(self, name, age):
    self.name = name
    self.age = age

  def __str__(self):
    return f"{self.name}({self.age})"

p1 = Person("John", 36)

print(p1)
# John(36)
```

## object methods
```python
class Person:
  def __init__(self, name, age):
    self.name = name
    self.age = age

  def myfunc(self):
    print("Hello my name is " + self.name)

p1 = Person("John", 36)
p1.myfunc()
```

## `self` parameter

```python
# 它不必命名为 self ，您可以随意调用它，但它必须是类中任何函数的第一个参数
class Person:
  def __init__(mysillyobject, name, age):
    mysillyobject.name = name
    mysillyobject.age = age

  def myfunc(abc):
    print("Hello my name is " + abc.name)

p1 = Person("John", 36)
p1.myfunc()

```


## 修改对象的属性
```python
class Person:
    def __init__(self, name, age):
        self.name = name
        self.age = age

        
p1 = Person("John", 36)

print(p1.name)
print(p1.age)

p1.age = 50
print(p1.age)
#John
#36
#50
```

## 删除属性
```python
class Person:
    def __init__(self, name, age):
        self.name = name
        self.age = age

        
p1 = Person("John", 36)

print(p1.name)
print(p1.age)

del p1.age
print(p1.age)
# John
# 36
# Traceback (most recent call last):
#   File "C:\Users\Tracy\Documents\Code\python\base\main.py", line 13, in <module>
#     print(p1.age)
#           ^^^^^^
# AttributeError: 'Person' object has no attribute 'age'
```


## 删除对象
```python
class Person:
    def __init__(self, name, age):
        self.name = name
        self.age = age

        
p1 = Person("John", 36)


del p1
```

## pass 
```python
# 类定义不能为空，但如果由于某种原因你有一个没有内容的类定义，请放入 pass 语句以避免出错。
class Person:
    pass
```

## 类继承
```python
# 创建一个名为 Person 的类，具有 firstname 和 lastname 属性，以及一个 printname 方法:
class Person:
    def __init__(self, fname, lname):
        self.firstname = fname
        self.lastname = lname

    def printname(self):
        print(self.firstname, self.lastname)


# Use the Person class to create an object, and then execute the printname method:

x = Person("John", "Doe")
x.printname()

# 要创建一个从另一个类继承功能的类，请在创建子类时将父类作为参数发送
class Student(Person):
    pass


y = Student("a", 'b')
y.printname()
# John Doe
# a b
```

```python
class Person:
    def __init__(self, fname, lname):
        self.firstname = fname
        self.lastname = lname

    def printname(self):
        print(self.firstname, self.lastname)
        
        
"""添加__init__()函数后，子类将不再继承父类的__init__()函数。
子类的 __init__() 函数覆盖了父类的 __init__() 函数的继承。"""
class Student(Person):
  def __init__(self, fname, lname):
    # add properties etc.


# 要保留对父级 __init__() 函数的继承，请添加对父级 __init__() 函数的调用
class Student(Person):
  def __init__(self, fname, lname):
    Person.__init__(self, fname, lname)
```

## super()
```python
# 还有一个 super() 函数，可以让子类继承父类的所有方法和属性
class Student(Person):
  def __init__(self, fname, lname):
    super().__init__(fname, lname)
# 通过使用 super() 函数，您不必使用父元素的名称，它会自动从其父元素继承方法和属性。
```

## 添加属性
```python
class Student(Person):
  def __init__(self, fname, lname):
    super().__init__(fname, lname)
    self.graduationyear = 2019


class Student(Person):
  def __init__(self, fname, lname, year):
    super().__init__(fname, lname)
    self.graduationyear = year

x = Student("Mike", "Olsen", 2019)
```

## 添加方法
```python
class Student(Person):
  def __init__(self, fname, lname, year):
    super().__init__(fname, lname)
    self.graduationyear = year

  def welcome(self):
    print("Welcome", self.firstname, self.lastname, "to the class of", self.graduationyear)
```