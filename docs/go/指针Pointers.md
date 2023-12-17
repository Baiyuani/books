## 指针

!!! info
    - `&` 操作符会生成一个指向其操作数的指针。
    
    - `*` 操作符表示指针指向的底层值。
    
    - 简单来说，通过`&`设置指针，通过`*`使用指针。

```go
//zeroval 不会更改 main 中的 i，但 zeroptr 会更改，因为它引用了该变量的内存地址。
package main

import "fmt"

func zeroval(ival int) {
    ival = 0
}
//zeroptr 有一个 *int 参数，这意味着它需要一个 int 指针。然后函数体中的 *iptr 代码将指针从其内存地址取消引用到该地址的当前值。为取消引用的指针赋值会更改引用地址处的值。
func zeroptr(iptr *int) {
    *iptr = 0
}

func main() {
    i := 1
    fmt.Println("initial:", i)

    zeroval(i)
    fmt.Println("zeroval:", i)
    //&i 语法给出了 i 的内存地址，即指向 i 的指针
    zeroptr(&i)
    fmt.Println("zeroptr:", i)

    fmt.Println("pointer:", &i)
}
```
