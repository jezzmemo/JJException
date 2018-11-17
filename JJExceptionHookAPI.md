
* NSObject(UnrecognizedSelectorHook)

```
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector;
- (void)forwardInvocation:(NSInvocation *)anInvocation;
```

* NSObject(KVOCrash)

```
- (void) addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath 
						options:(NSKeyValueObservingOptions)options context:(void *)context;
- (void) removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;
- (void) removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(nullable void *)context;
```

* NSString

```
+ (NSString*) stringWithUTF8String:(const char *)nullTerminatedCString;
+ (nullable instancetype) stringWithCString:(const char *)cString encoding:(NSStringEncoding)enc;
- (nullable instancetype) initWithCString:(const char *)nullTerminatedCString encoding:(NSStringEncoding)encoding;
- (NSString *)substringFromIndex:(NSUInteger)from;
- (NSString *)substringToIndex:(NSUInteger)to;
- (NSString *)substringWithRange:(NSRange)range;
```

* NSMutableString

```
- (nullable instancetype) safeInitWithCString:(const char *)nullTerminatedCString encoding:(NSStringEncoding)encoding;
- (void) appendString:(NSString *)aString;
- (void) insertString:(NSString *)aString atIndex:(NSUInteger)loc;
- (void) deleteCharactersInRange:(NSRange)range;
- (NSString *)stringByAppendingString:(NSString *)aString;
```

* NSArray

```
+ (instancetype) arrayWithObject:(id)anObject;
- (id) objectAtIndex:(NSUInteger)index;
- (NSArray<ObjectType> *)subarrayWithRange:(NSRange)range;
- (id) objectAtIndexedSubscript:(NSInteger)index
```

* NSMutableArray

```
- (void) addObject:(id)anObject;
- (id) objectAtIndex:(NSUInteger)index;
- (void) insertObject:(id)anObject atIndex:(NSUInteger)index;
- (void) removeObjectAtIndex:(NSUInteger)index;
- (void) replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;
- (void) removeObjectsInRange:(NSRange)range;
```

* NSDictionary

```
+ (instancetype) dictionaryWithObject:(id)object forKey:(id)key;
- (id) objectForKey:(id)aKey;
```

* NSMutableDictionary

```
- (void) setObject:(id)anObject forKey:(id)aKey;
- (void) removeObjectForKey:(id)aKey;
```

* NSSet

```
+ (instancetype)setWithObject:(id)object;
```

* NSMutableSet

```
- (void) addObject:(id)object;
- (void) removeObject:(id)object;
```
