# Candle Lang

## Todo


- Alias tests
- Use Alias instead of TypeRef for struct/union/enum ?


Emitter.emit(Project):

reorderTopLevelTypes(project)

Write all struct, union, enum or aliases to Project parent so that we can order them properly
Then order them all with respect to each other
Then emit them all before emitting any units



- Type inference - auto

- (type,type->type) {}

- Function literals (lambdas)
- Assign to function pointers 

- Arrays
- Enums
- Unions
- Templates

### Idea - Function Literals
```
(type,type->type) {}
```

 Maybe do the same for function declarations::
```
 foo (type,type->type) {}
```

### Multiple return values

```

```

### Tuples

```

```