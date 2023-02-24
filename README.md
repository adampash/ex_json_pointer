# ExJSONPointer

An implementation of [RFC 6901](https://www.rfc-editor.org/rfc/rfc6901.html) that JSON pointer defines a string syntax for
identifying a specific value within a JSON document.

## Usage

The JSON pointer string syntax can be represented as a JSON string:

```elixir
iex(1)> ExJSONPointer.evaluate(%{"a" => %{"b" => %{"c" => "hello"}}}, "/a/b/c")
"hello"
iex(2)> ExJSONPointer.evaluate(%{"a" => %{"b" => %{"c" => "hello"}}}, "/a/b")
%{"c" => "hello"}
iex(3)> ExJSONPointer.evaluate(%{"a" => %{"b" => %{"c" => [1, 2, 3]}}}, "/a/b/c")
[1, 2, 3]
iex(4)> ExJSONPointer.evaluate(%{"a" => %{"b" => %{"c" => [1, 2, 3]}}}, "/a/b/c/2")
3
iex(5)> ExJSONPointer.evaluate(%{"a" => [%{"b" => %{"c" => [1, 2]}}, 2, 3]}, "/a/2")
3
iex(6)> ExJSONPointer.evaluate(%{"a" => [%{"b" => %{"c" => [1, 2]}}, 2, 3]}, "/a/0/b/c/1")
2
```

or a URI fragment identifier:

```elixir
iex(1)> ExJSONPointer.evaluate(%{"a" => %{"b" => %{"c" => "hello"}}}, "#/a/b/c")
"hello"
iex(2)> ExJSONPointer.evaluate(%{"a" => %{"b" => %{"c" => "hello"}}}, "#/a/b")
%{"c" => "hello"}
iex(3)> ExJSONPointer.evaluate(%{"a" => %{"b" => %{"c" => [1, 2, 3]}}}, "#/a/b/c")
[1, 2, 3]
iex(4)> ExJSONPointer.evaluate(%{"a" => %{"b" => %{"c" => [1, 2, 3]}}}, "#/a/b/c/2")
3
iex(5)> ExJSONPointer.evaluate(%{"a" => [%{"b" => %{"c" => [1, 2]}}, 2, 3]}, "#/a/2")
3
iex(6)> ExJSONPointer.evaluate(%{"a" => [%{"b" => %{"c" => [1, 2]}}, 2, 3]}, "#/a/0/b/c/1")
2
```

Some cases that a JSON pointer that references a nonexistent value:

```elixir
iex(1)> ExJSONPointer.evaluate(%{"a" => %{"b" => %{"c" => "hello"}}}, "/a/b/d")
nil
iex(2)> ExJSONPointer.evaluate(%{"a" => %{"b" => %{"c" => [1, 2, 3]}}}, "/a/b/c/4")
nil
iex(3)> ExJSONPointer.evaluate(%{"a" => %{"b" => %{"c" => "hello"}}}, "#/a/b/d")
nil
iex(4)> ExJSONPointer.evaluate(%{"a" => %{"b" => %{"c" => [1, 2, 3]}}}, "#/a/b/c/4")
nil
```

Invalid pointer syntax:

```elixir
iex(1)> ExJSONPointer.evaluate(%{"a" => %{"b" => %{"c" => [1, 2, 3]}}}, "a/b")
{:error,
 "Invalid JSON pointer syntax that not represented starts with `#` or `/`"}
```
