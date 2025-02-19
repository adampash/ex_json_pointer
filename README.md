# ExJSONPointer

[![hex.pm version](https://img.shields.io/hexpm/v/ex_json_pointer.svg?v=1)](https://hex.pm/packages/ex_json_pointer)

<!-- MDOC !-->

An Elixir implementation of [RFC 6901](https://www.rfc-editor.org/rfc/rfc6901.html) JSON Pointer for locating specific values within JSON documents.

## Usage

The JSON pointer string syntax can be represented as a JSON string:

```elixir
iex> ExJSONPointer.resolve(%{"a" => %{"b" => %{"c" => "hello"}}}, "/a/b/c")
"hello"

iex> ExJSONPointer.resolve(%{"a" => %{"b" => %{"c" => "hello"}}}, "/a/b")
%{"c" => "hello"}

iex> ExJSONPointer.resolve(%{"a" => %{"b" => %{"c" => [1, 2, 3]}}}, "/a/b/c")
[1, 2, 3]

iex> ExJSONPointer.resolve(%{"a" => %{"b" => %{"c" => [1, 2, 3]}}}, "/a/b/c/2")
3

iex> ExJSONPointer.resolve(%{"a" => [%{"b" => %{"c" => [1, 2]}}, 2, 3]}, "/a/2")
3

iex> ExJSONPointer.resolve(%{"a" => [%{"b" => %{"c" => [1, 2]}}, 2, 3]}, "/a/0/b/c/1")
2
```

or a URI fragment identifier:

```elixir
iex> ExJSONPointer.resolve(%{"a" => %{"b" => %{"c" => "hello"}}}, "#/a/b/c")
"hello"

iex> ExJSONPointer.resolve(%{"a" => %{"b" => %{"c" => "hello"}}}, "#/a/b")
%{"c" => "hello"}

iex> ExJSONPointer.resolve(%{"a" => %{"b" => %{"c" => [1, 2, 3]}}}, "#/a/b/c")
[1, 2, 3]

iex> ExJSONPointer.resolve(%{"a" => %{"b" => %{"c" => [1, 2, 3]}}}, "#/a/b/c/2")
3

iex> ExJSONPointer.resolve(%{"a" => [%{"b" => %{"c" => [1, 2]}}, 2, 3]}, "#/a/2")
3

iex> ExJSONPointer.resolve(%{"a" => [%{"b" => %{"c" => [1, 2]}}, 2, 3]}, "#/a/0/b/c/1")
2
```

Some cases that a JSON pointer that references a nonexistent value:

```elixir
iex> ExJSONPointer.resolve(%{"a" => %{"b" => %{"c" => "hello"}}}, "/a/b/d")
nil

iex> ExJSONPointer.resolve(%{"a" => %{"b" => %{"c" => [1, 2, 3]}}}, "/a/b/c/4")
nil

iex> ExJSONPointer.resolve(%{"a" => %{"b" => %{"c" => "hello"}}}, "#/a/b/d")
nil

iex> ExJSONPointer.resolve(%{"a" => %{"b" => %{"c" => [1, 2, 3]}}}, "#/a/b/c/4")
nil

```

Empty Reference token cases:

```elixir
iex> ExJSONPointer.resolve(%{"" => %{"" => 1}}, "/")
%{"" => 1} 

iex> ExJSONPointer.resolve(%{"" => %{"" => 1}}, "//")
1

iex> ExJSONPointer.resolve(%{"" => %{"" => 1, "b" => %{"" => 2}}}, "//b")
%{"" => 2}

iex> ExJSONPointer.resolve(%{"" => %{"" => 1, "b" => %{"" => 2}}}, "//b/")
2

iex> ExJSONPointer.resolve(%{"" => %{"" => 1, "b" => %{"" => 2}}}, "//b///")
nil
```

Invalid JSON pointer syntax:

```elixir
iex> ExJSONPointer.resolve(%{"a" =>%{"b" => %{"c" => [1, 2, 3]}}}, "a/b")
{:error,
  "invalid JSON pointer syntax that not represented starts with `#` or `/`"}

iex> ExJSONPointer.resolve(%{"a" =>%{"b" => %{"c" => [1, 2, 3]}}}, "##/a")
{:error,
  "invalid URI fragment identifier"}

```

Please see the test cases for more examples.
