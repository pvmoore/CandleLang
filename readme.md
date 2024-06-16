# Candle Lang

## Todo


defining struct methods
calling struct methods

- Function literals (lambdas)
- Assign to function pointers 

- Arrays
- Enums
- Unions
- Templates

- Type inference - auto

### Templates

```c
struct List<T> {
    T a;
}
func foo<T>(T t) {}
```

### Arrays And Slices

An array is always static.
```c
int[6] staticArray;
staticArray = [1,2,3,4,5,6]; 

struct slice<T> {
    T* ptr;
    ulong length;
}

slice<int> slice = staticArray[0..3];
```

### Function Literals
```c
(type,type->type) {}


(type,type->type) foo = (a,b) { return 0; }
```

### Tuples

```c
struct(int,float,double) tuple;
```

Using tuples:
```c
func foo(void->int, float) { 
    return struct(1, 3.4f); 
}
```