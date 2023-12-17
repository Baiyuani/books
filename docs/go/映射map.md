!!! info 

    Maps are used to store data values in key:value pairs.

    Each element in a map is a key:value pair.
    
    A map is an unordered and changeable collection that does not allow duplicates.
    
    The length of a map is the number of its elements. You can find it using the len() function.
    
    The default value of a map is nil.
    
    Maps hold references to an underlying hash table.
    
    Go has multiple ways for creating maps.


### 零值map

=== "映射的零值为 nil 。nil 映射既没有键，也不能添加键。"

    ```go
    var a = map[KeyType]ValueType{key1:value1, key2:value2,...}
    b := map[KeyType]ValueType{key1:value1, key2:value2,...}
    ```

=== "Example"

    ```go
    package main
    import ("fmt")
    
    func main() {
      var a = map[string]string{"brand": "Ford", "model": "Mustang", "year": "1964"}
      b := map[string]int{"Oslo": 1, "Bergen": 2, "Trondheim": 3, "Stavanger": 4}
    
      fmt.Printf("a\t%v\n", a)
      fmt.Printf("b\t%v\n", b)
    }
    ```

!!! note
    
    注意：代码中定义的地图元素的顺序与其存储方式不同。数据的存储方式可以从地图中高效地检索数据

    ```go
    //使用make()函数声明map
    var a = make(map[KeyType]ValueType)
    b := make(map[KeyType]ValueType)
    ```

```go
package main
import ("fmt")

func main() {
  var a = make(map[string]string) // The map is empty now
  a["brand"] = "Ford"
  a["model"] = "Mustang"
  a["year"] = "1964"
                                 // a is no longer empty
  b := make(map[string]int)
  b["Oslo"] = 1
  b["Bergen"] = 2
  b["Trondheim"] = 3
  b["Stavanger"] = 4

  fmt.Printf("a\t%v\n", a)
  fmt.Printf("b\t%v\n", b)
}
```

## 空map

!!! note

    注意：make() 函数是创建空映射的正确方法。如果你以不同的方式制作一个空映射并写入它，它会导致运行时恐慌。

```go
//创建一个空map
var a map[KeyType]ValueType
```

```go
package main
import ("fmt")

func main() {
  var a = make(map[string]string)
  var b map[string]string

  fmt.Println(a == nil)
  fmt.Println(b == nil)
}
```

## 允许的key类型

- [x] Booleans
- [x] Numbers
- [x] Strings
- [x] Arrays
- [x] Pointers
- [x] Structs
- [x] Interfaces (as long as the dynamic type supports equality)
- [ ] Slices
- [ ] Maps
- [ ] Functions

## 允许的value类型

- [x] Any

## map元素操作

### 获取map中的元素

```go
value = map_name[key]
```

```go
package main
import ("fmt")

func main() {
  var a = make(map[string]string)
  a["brand"] = "Ford"
  a["model"] = "Mustang"
  a["year"] = "1964"

  fmt.Printf(a["brand"])
}
```

### 更新和添加map元素

```go
map_name[key] = value
```

```go
package main
import ("fmt")

func main() {
  var a = make(map[string]string)
  a["brand"] = "Ford"
  a["model"] = "Mustang"
  a["year"] = "1964"

  fmt.Println(a)

  a["year"] = "1970" // Updating an element
  a["color"] = "red" // Adding an element

  fmt.Println(a)
}
```

### 删除元素

```go
delete(map_name, key)
```

```go
package main
import ("fmt")

func main() {
  var a = make(map[string]string)
  a["brand"] = "Ford"
  a["model"] = "Mustang"
  a["year"] = "1964"

  fmt.Println(a)

  delete(a,"year")

  fmt.Println(a)
}
```

### 检查map中的特定元素

```go
val, ok := map_name[key]
```

```go
package main
import ("fmt")

func main() {
  var a = map[string]string{"brand": "Ford", "model": "Mustang", "year": "1964", "day":""}

  val1, ok1 := a["brand"] // Checking for existing key and its value
  val2, ok2 := a["color"] // Checking for non-existing key and its value
  val3, ok3 := a["day"]   // Checking for existing key and its value
  //如果只想检查某个key是否存在，可以用空白标识符（_）代替val。
  _, ok4 := a["model"]    // Only checking for existing key and not its value

  fmt.Println(val1, ok1)
  fmt.Println(val2, ok2)
  fmt.Println(val3, ok3)
  fmt.Println(ok4)
}
```

## 映射是对哈希表的引用

如果两个映射变量引用同一个哈希表，则更改一个变量的内容会影响另一个变量的内容。

```go
package main
import ("fmt")

func main() {
  var a = map[string]string{"brand": "Ford", "model": "Mustang", "year": "1964"}
  b := a

  fmt.Println(a)
  fmt.Println(b)

  b["year"] = "1970"
  fmt.Println("After change to b:")

  fmt.Println(a)
  fmt.Println(b)
}
```

## 遍历map

```go
package main
import ("fmt")

func main() {
  a := map[string]int{"one": 1, "two": 2, "three": 3, "four": 4}

  for k, v := range a {
    fmt.Printf("%v : %v, ", k, v)
  }
}
```

### 以指定条件遍历map

```go
package main
import ("fmt")

func main() {
  a := map[string]int{"one": 1, "two": 2, "three": 3, "four": 4}

  var b = []string{}             // defining the order
  b = append(b, "one", "two", "three", "four")

  for k, v := range a {        // loop with no order
    fmt.Printf("%v : %v, ", k, v)
  }

  fmt.Println()

  for _, element := range b {  // loop with the defined order
    fmt.Printf("%v : %v, ", element, a[element])
  }
}
```
