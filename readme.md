# Candle Lang

![Logo](/resources/logo-small.png)

## Todo

Defining struct methods

Calling struct methods (UFCS)

- Function literals (lambdas)
- Assign to function pointers 

- Arrays
- Enums
- Unions
- Templates
- Array indexing
- Type inference - auto

### Templates

```rust
struct List<T> {
    T a;
}
func foo<T>(T t) {}
```

### Arrays And Slices

An array is always a static value.
```rust
int[6] staticArray;
staticArray = [1,2,3,4,5,6]; 

struct slice<T> {
    T* ptr;
    ulong length;
}

slice<int> slice = staticArray.slice(0,3);
```

### Function Literals
```rust
func (type,type->type) foo = (a,b) { return 0; }
```

### Tuples

```rust
struct(int,float,double) tuple;

func foo(void -> struct(int, float)) { 
    return {1, 3.4}; 
}
```

### Struct Literals

```rust
MyStruct s   = MyStruct{ a: 10, b: 20 }
MyStruct s   = { a: 10, b: 20 };
auto s       = { a:10, b: 20 } as MyStruct;
MyStruct* s2 = @alloc(g_arena) MyStruct{ a: 2 } 
```

### Scope

```rust
scope Allocator{1000} alloc {
    // implicit alloc.scopeBegin()

    string s = "hello".toUpper(alloc)

    // implicit alloc.scopeEnd()
}
```
