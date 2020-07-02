
* NSObject(UnrecognizedSelectorHook)

```
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector;
- (void)forwardInvocation:(NSInvocation *)anInvocation;
```

```
+ (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector;
+ (void)forwardInvocation:(NSInvocation *)anInvocation;
```

* NSObject(KVOCrash)

```
- (void) addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath 
						options:(NSKeyValueObservingOptions)options context:(void *)context;
- (void) removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;
- (void) removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(nullable void *)context;
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context;
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

* NSAttributedString

```
- (instancetype)initWithString:(NSString *)str;
- (NSAttributedString *)attributedSubstringFromRange:(NSRange)range;
- (nullable id)attribute:(NSAttributedStringKey)attrName atIndex:(NSUInteger)location effectiveRange:(nullable NSRangePointer)range;
- (void)enumerateAttribute:(NSAttributedStringKey)attrName inRange:(NSRange)enumerationRange options:(NSAttributedStringEnumerationOptions)opts usingBlock:(void (NS_NOESCAPE ^)(id _Nullable value, NSRange range, BOOL *stop))block;
- (void)enumerateAttributesInRange:(NSRange)enumerationRange options:(NSAttributedStringEnumerationOptions)opts usingBlock:(void (NS_NOESCAPE ^)(NSDictionary<NSAttributedStringKey, id> *attrs, NSRange range, BOOL *stop))block;
```

* NSMutableAttributedString

```
- (instancetype)initWithString:(NSString *)str;
- (instancetype)initWithString:(NSString *)str attributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attrs;
- (void)addAttribute:(NSAttributedStringKey)name value:(id)value range:(NSRange)range;
- (void)addAttributes:(NSDictionary<NSAttributedStringKey, id> *)attrs range:(NSRange)range;
- (void)removeAttribute:(NSAttributedStringKey)name range:(NSRange)range;
- (void)replaceCharactersInRange:(NSRange)range withAttributedString:(NSAttributedString *)attrString;
- (void)deleteCharactersInRange:(NSRange)range;
- (void)setAttributedString:(NSAttributedString *)attrString;
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
- (void) setObject:(id)object atIndexedSubscript:(NSUInteger)index;
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
- (void) setObject:(id)object forKeyedSubscript:(id<NSCopying>)key;
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

* NSTimer

```
+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo;
```

* NSNotificationCenter

```
- (void)addObserver:(id)observer selector:(SEL)aSelector name:(nullable NSNotificationName)aName object:(nullable id)anObject;
```
