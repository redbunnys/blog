---
title: "go 反射简单使用(Reflect)"
date: 2023-05-25T13:53:24+08:00
draft: false
description: "反射的简单使用"
featured_image: "https://w.wallhaven.cc/full/5g/wallhaven-5g7ew7.jpg"
comment : false
hidden: false
tags: ["reflect"]
Categories: "go"
---

# 反射

> 介绍基本使用，具体深入点击下面的链接
>
> 深入理解 :[点击跳转](https://draveness.me/golang/docs/part2-foundation/ch04-basic/golang-reflect/)
## 使用反射


虽然在大多数的应用和服务中并不常见，但是很多框架都依赖 Go 语言的反射机制简化代码。因为 Go 语言的语法元素很少、设计简单，所以它没有特别强的表达能力，但是 Go 语言的 reflect 包能够弥补它在语法上reflect.Type的一些劣势。

reflect 实现了运行时的反射能力，能够让程序操作不同类型的对象。

反射主要围绕这两个函数运行:
- reflect.TypeOf 能获取类型信息
- reflect.ValueOf 能获取数据的运行时表示

### 反射(reflect.TypeOf reflect.ValueOf)

#### 获取一个变量
~~~go
strings := 123

t := reflect.TypeOf(strings)
v := reflect.ValueOf(strings)

fmt.Println(t)
fmt.Println(v)
~~~
output: int 123

TypeOf 主要获取变量的类型
ValueOf 主要获取变量的值


####
下面来一个结构体

~~~go
type student struct {
	name string
	age  int
}

func main() {
	s := student{
		name: "go",
		age:  16,
	}
	t := reflect.TypeOf(s)
	v := reflect.ValueOf(s)

	fmt.Println(t)
	fmt.Println(v)

	for i := 0; i < v.NumField(); i++ {
		fmt.Printf("type:%v,value:%v\n", v.Field(i).Type(), v.Field(i))
	}

}
~~~

这里用到了`for`  是因为结构体里面有多个字段
1. `reflect.ValueOf(s).NumField()` 是获取结构体里面有多少个字段
2. `reflect.ValueOf(s).Field([index])` 是 `reflect.Value` 一个方法，获取字段里的值


#### Kind  方法

主要获取当前传入的类型

~~~go
func main() {
	s := student{
		name: "go",
		age:  16,
	}
	t := reflect.TypeOf(s)
	v := reflect.ValueOf(s)

	fmt.Println("TypeOfKind:", t.Kind())
	fmt.Println("ValueOfKind:", v.Kind())

	f := 3.14159
	t = reflect.TypeOf(f)
	v = reflect.ValueOf(f)

	fmt.Println("TypeOfKind:", t.Kind())
	fmt.Println("ValueOfKind:", v.Kind())
}

//output:
//TypeOfKind: struct
//ValueOfKind: struct

//TypeOfKind: float64
//ValueOfKind: float64
~~~
可以看出 结构体是 `struct`,定义变量是 `float`,但是结构体里面有其他的字段，每个字段 类型也不一样，也可以获取

~~~go
func main() {
	s := student{
		name: "go",
		age:  16,
	}
	t := reflect.TypeOf(s)
	v := reflect.ValueOf(s)

	for i := 0; i < v.NumField(); i++ {
		fmt.Printf("typeKind:%v,valueKind:%v\n", v.Field(i).Type().Kind(), v.Field(i).Kind())
	}
}
//typeKind:string,valueKind:string
//typeKind:int,valueKind:int
~~~

#### 通过反射修改值

~~~go
func main() {
	f := 3.14
	v := reflect.ValueOf(&f)
    //获取原始指针
	Uv := v.Elem()
	fmt.Println("values:", Uv)
    //这里是float 所以设置float值
	Uv.SetFloat(1.3456)
	fmt.Println("values:", Uv)
}
//values: 3.14
//values: 1.3456
~~~
传入的一定要是指针否则会报错，


#### 反射实现一个sql生成器demo

~~~go
func main() {
	s := student{
		name: "go",
		age:  16,
	}
	fmt.Println(QueryCreate(s))
}
func QueryCreate(value interface{}) string {

	t := reflect.TypeOf(value)
	v := reflect.ValueOf(value)
	sql := fmt.Sprintf("insert into  %s", t.Name())
	columns := "("
	values := "values ("
	for i := 0; i < v.NumField(); i++ {
		switch v.Field(i).Kind() {
		case reflect.Int:
			if i == 0 {
				columns += fmt.Sprintf("%s", t.Field(i).Name)
				values += fmt.Sprintf("%d", v.Field(i).Int())
			} else {
				columns += fmt.Sprintf(", %s", t.Field(i).Name)
				values += fmt.Sprintf(", %d", v.Field(i).Int())
			}
		case reflect.String:
			if i == 0 {
				columns += fmt.Sprintf("%s", t.Field(i).Name)
				values += fmt.Sprintf("'%s'", v.Field(i).String())
			} else {
				columns += fmt.Sprintf(", %s", t.Field(i).Name)
				values += fmt.Sprintf(", '%s'", v.Field(i).String())
			}
		}

	}
	columns += "); "
	values += "); "
	sql += columns + values
	return sql
}
//output: insert into  student(name, age); values ('go', 16);
~~~