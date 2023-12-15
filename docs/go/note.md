# Note

## 初始化项目linux

```shell
curl -O https://dl.google.com/go/go1.21.5.linux-amd64.tar.gz

rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz

# 设置go环境变量
sudo tee /etc/profile.d/go.sh << 'EOF'
export GOROOT=/usr/local/go
export PATH=$PATH:/usr/local/go/bin
EOF
# 设置代理
sudo tee /etc/profile.d/custom_proxy.sh << 'EOF'
export no_proxy=127.0.0.1,192.168.*,172.31.*,172.30.*,172.29.*,172.28.*,172.27.*,172.26.*,172.25.*,172.24.*,172.23.*,172.22.*,172.21.*,172.20.*,172.19.*,172.18.*,172.17.*,172.16.*,10.*,127.*,localhost,$(awk -F[\#] '{print $1}' /etc/hosts | sed -r /^$/d | awk '{res=res$2","}END{print res}')
export NO_PROXY=127.0.0.1,192.168.*,172.31.*,172.30.*,172.29.*,172.28.*,172.27.*,172.26.*,172.25.*,172.24.*,172.23.*,172.22.*,172.21.*,172.20.*,172.19.*,172.18.*,172.17.*,172.16.*,10.*,127.*,localhost,$(awk -F[\#] '{print $1}' /etc/hosts | sed -r /^$/d | awk '{res=res$2","}END{print res}')
export HTTPS_PROXY=http://192.168.182.1:29998
export https_proxy=http://192.168.182.1:29998
export HTTP_PROXY=http://192.168.182.1:29998
export http_proxy=http://192.168.182.1:29998
EOF

go version
```


## 初始化项目windows

```shell
mkdir xxx
cd xxx

# 生成go.mod文件，命名项目
go mod init xxx

# 将项目中应用的包下载到本地，并生成go.sum用于验证，并更新go.mod。自动检查当前模块的依赖关系，并移除不需要的依赖项
go mod tidy

# 用于更新指定的包及其所有依赖包到最新版本，并重新编译安装它们
go get .

# 运行go脚本
go run helloworld.go

# 将程序打包为可执行文件
go build helloworld.go

# go install 命令构建并安装由命令行上的路径命名的包。 
# 可执行文件（主要包）安装到由 GOBIN 环境变量命名的目录，
# 如果未设置 GOPATH 环境变量，则默认为 $GOPATH/bin 或 $HOME/go/bin。 
# $GOROOT 中的可执行文件安装在 $GOROOT/bin 或 $GOTOOLDIR 而不是 $GOBIN。 
# 构建和缓存非可执行包但不安装。
go install golang.org/x/tools/gopls@latest

# 修改go环境变量
go env -w GOBIN=/path/to/your/bin
# go env -w GOBIN=C:\path\to\your\bin
```

    左大括号不能在行首。
    程序从 main 包开始运行。
    按照约定，包名与导入路径的最后一个元素一致。例如，"math/rand" 包中的源码均以 package rand 语句开始。
    在 Go 中，如果一个名字以大写字母开头，那么它就是已导出的。例如，Pizza 就是个已导出名，Pi 也同样，它导出自 math 包。pizza 和 pi 并未以大写字母开头，所以它们是未导出的。在导入一个包时，你只能引用其中已导出的名字。任何“未导出”的名字在该包外均无法访问。
    
## 单行注释

```go
// This is a comment
package main
import ("fmt")

func main() {
  // This is a comment
  fmt.Println("Hello World!")
}
```

## 多行注释

```go
package main
import ("fmt")

func main() {
  /* The code below will print Hello World
  to the screen, and it is amazing */
  fmt.Println("Hello World!")
}
```

## 输出

```go
//Println() 函数类似于 Print() ，不同之处在于参数之间添加了一个空格，最后添加了一个换行符
package main
import ("fmt")

func main() {
  var i,j string = "Hello","World"

  fmt.Println(i,j)
}
```

### printf的格式化操作表(https://www.w3schools.com/go/go_formatting_verbs.php)

```go
//Printf() 函数首先根据给定的格式化动词格式化其参数，然后打印
// %v	Prints the value in the default format
// %#v	Prints the value in Go-syntax format
// %T	Prints the type of the value
// %%	Prints the % sign
package main
import ("fmt")

func main() {
  var i string = "Hello"
  var j int = 15

  fmt.Printf("i has value: %v and type: %T\n", i, i)
  fmt.Printf("j has value: %v and type: %T", j, j)
}
```

## url解析

```go
package main

import (
    "fmt"
    "net"
    "net/url"
)

func main() {

    s := "postgres://user:pass@host.com:5432/path?k=v#f"

    u, err := url.Parse(s)
    if err != nil {
        panic(err)
    }

    fmt.Println(u.Scheme)

    fmt.Println(u.User)
    fmt.Println(u.User.Username())
    p, _ := u.User.Password()
    fmt.Println(p)

    fmt.Println(u.Host)
    host, port, _ := net.SplitHostPort(u.Host)
    fmt.Println(host)
    fmt.Println(port)

    fmt.Println(u.Path)
    fmt.Println(u.Fragment)

    fmt.Println(u.RawQuery)
    m, _ := url.ParseQuery(u.RawQuery)
    fmt.Println(m)
    fmt.Println(m["k"][0])
}
```


## [xml](https://gobyexample.com/xml)

## 随机数

```go
package main

import (
    "fmt"
    "math/rand"
    "time"
)

func main() {

    fmt.Print(rand.Intn(100), ",")
    fmt.Print(rand.Intn(100))
    fmt.Println()

    fmt.Println(rand.Float64())

    fmt.Print((rand.Float64()*5)+5, ",")
    fmt.Print((rand.Float64() * 5) + 5)
    fmt.Println()

    s1 := rand.NewSource(time.Now().UnixNano())
    r1 := rand.New(s1)

    fmt.Print(r1.Intn(100), ",")
    fmt.Print(r1.Intn(100))
    fmt.Println()

    s2 := rand.NewSource(42)
    r2 := rand.New(s2)
    fmt.Print(r2.Intn(100), ",")
    fmt.Print(r2.Intn(100))
    fmt.Println()
    s3 := rand.NewSource(42)
    r3 := rand.New(s3)
    fmt.Print(r3.Intn(100), ",")
    fmt.Print(r3.Intn(100))
}
```

## 从字符串中解析数字

```go
package main

import (
    "fmt"
    "strconv"
)

func main() {

    f, _ := strconv.ParseFloat("1.234", 64)
    fmt.Println(f)

    i, _ := strconv.ParseInt("123", 0, 64)
    fmt.Println(i)

    d, _ := strconv.ParseInt("0x1c8", 0, 64)
    fmt.Println(d)

    u, _ := strconv.ParseUint("789", 0, 64)
    fmt.Println(u)

    k, _ := strconv.Atoi("135")
    fmt.Println(k)

    _, e := strconv.Atoi("wat")
    fmt.Println(e)
}
```


## sha256

```go
package main

import (
    "crypto/sha256"
    "fmt"
)

func main() {
    s := "sha256 this string"

    h := sha256.New()

    h.Write([]byte(s))

    bs := h.Sum(nil)

    fmt.Println(s)
    fmt.Printf("%x\n", bs)
}
```

## [base64](https://gobyexample.com/base64-encoding)

```go
package main

import (
    b64 "encoding/base64"
    "fmt"
)

func main() {

    data := "abc123!?$*&()'-=@~"

    sEnc := b64.StdEncoding.EncodeToString([]byte(data))
    fmt.Println(sEnc)

    sDec, _ := b64.StdEncoding.DecodeString(sEnc)
    fmt.Println(string(sDec))
    fmt.Println()

    uEnc := b64.URLEncoding.EncodeToString([]byte(data))
    fmt.Println(uEnc)
    uDec, _ := b64.URLEncoding.DecodeString(uEnc)
    fmt.Println(string(uDec))
}
```

## [Line Filters](https://gobyexample.com/line-filters)

```go
package main

import (
    "bufio"
    "fmt"
    "os"
    "strings"
)

func main() {

    scanner := bufio.NewScanner(os.Stdin)

    for scanner.Scan() {

        ucl := strings.ToUpper(scanner.Text())

        fmt.Println(ucl)
    }

    if err := scanner.Err(); err != nil {
        fmt.Fprintln(os.Stderr, "error:", err)
        os.Exit(1)
    }
}
```

## 获取环境变量

```go
package main

import (
    "fmt"
    "os"
    "strings"
)

func main() {

    os.Setenv("FOO", "1")
    fmt.Println("FOO:", os.Getenv("FOO"))
    fmt.Println("BAR:", os.Getenv("BAR"))

    fmt.Println()
    for _, e := range os.Environ() {
        pair := strings.SplitN(e, "=", 2)
        fmt.Println(pair[0])
    }
}
```

## [调用其他程序](https://gobyexample.com/spawning-processes)

```go
package main

import (
    "fmt"
    "io"
    "os/exec"
)

func main() {

    dateCmd := exec.Command("date")

    dateOut, err := dateCmd.Output()
    if err != nil {
        panic(err)
    }
    fmt.Println("> date")
    fmt.Println(string(dateOut))

    _, err = exec.Command("date", "-x").Output()
    if err != nil {
        switch e := err.(type) {
        case *exec.Error:
            fmt.Println("failed executing:", err)
        case *exec.ExitError:
            fmt.Println("command exit rc =", e.ExitCode())
        default:
            panic(err)
        }
    }

    grepCmd := exec.Command("grep", "hello")

    grepIn, _ := grepCmd.StdinPipe()
    grepOut, _ := grepCmd.StdoutPipe()
    grepCmd.Start()
    grepIn.Write([]byte("hello grep\ngoodbye grep"))
    grepIn.Close()
    grepBytes, _ := io.ReadAll(grepOut)
    grepCmd.Wait()

    fmt.Println("> grep hello")
    fmt.Println(string(grepBytes))

    lsCmd := exec.Command("bash", "-c", "ls -a -l -h")
    lsOut, err := lsCmd.Output()
    if err != nil {
        panic(err)
    }
    fmt.Println("> ls -a -l -h")
    fmt.Println(string(lsOut))
}
```

### [调用其他程序，完全替换GO进程](https://gobyexample.com/execing-processes)

```go
package main

import (
    "os"
    "os/exec"
    "syscall"
)

func main() {

    binary, lookErr := exec.LookPath("ls")
    if lookErr != nil {
        panic(lookErr)
    }

    args := []string{"ls", "-a", "-l", "-h"}

    env := os.Environ()

    execErr := syscall.Exec(binary, args, env)
    if execErr != nil {
        panic(execErr)
    }
}
```

## signal

```go
package main

import (
    "fmt"
    "os"
    "os/signal"
    "syscall"
)

func main() {

    sigs := make(chan os.Signal, 1)

    signal.Notify(sigs, syscall.SIGINT, syscall.SIGTERM)

    done := make(chan bool, 1)

    go func() {

        sig := <-sigs
        fmt.Println()
        fmt.Println(sig)
        done <- true
    }()

    fmt.Println("awaiting signal")
    <-done
    fmt.Println("exiting")
}
```

## exit

```go
package main

import (
    "fmt"
    "os"
)

func main() {
    //使用 os.Exit 时不会运行 defer
    defer fmt.Println("!")

    os.Exit(3)
}
```

