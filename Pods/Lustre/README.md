# Lustre

An imperfect but more performant implementation of the Result pattern in Swift.

Lustre defines an interface with several manual specializations to improve
compiler inference and and runtime performance over a `Box<T>`-based Result
type, such as that from [LlamaKit](https://github.com/LlamaKit/LlamaKit).

Day-to-day syntax of using Lustre's Result types are almost identical, except
in that you must chose specific types to use for Result instances.

`VoidResult` and `ObjectResult` are fully-implemented specializations ready
for use out of the box with no-return results and reference type results,
respectively.

`AnyResult` is a fallback for any value type. `Any` is used as storage of any
`T`. Types under 17 bytes in size will be stored inline, so results of
all primitive types and most Swift collection types will have the same
performance of a specialized generic enum. Larger types are stored using a
native buffer type internal to Swift.

The `CustomResult` protocol exists for manual specializations for custom types
of a known size. For example, a JSON-parsing library might provide a `JSON`
enum, and `JSONResult` would conform to `CustomResult` with a `.Success(JSON)`
case.

The common-case implementation of `Result<T>` is clearly the way forward. Until
Swift supports multi-payload generic enums, `Lustre.Result` mitigates the
performance problems around using a `Box<T>`-based Result type.

## Availability

Lustre is intended for Swift 1.2. Compatibility with future versions is not
guaranteed.

## What's up with the name?

Result `=>` Lustre. It's an anagram.
