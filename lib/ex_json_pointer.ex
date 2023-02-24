defmodule ExJSONPointer do
  @moduledoc """
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
  """

  @type document :: map()
  @type pointer :: String.t()
  @type result :: nil | term() | {:error, String.t()}

  @doc """
  Evaluate the JSON document with the given string syntax to the accompanying value.
  """
  @spec evaluate(document, pointer) :: result
  def evaluate(document, ""), do: document
  def evaluate(document, "#"), do: document

  def evaluate(document, pointer)
      when is_map(document) and is_bitstring(pointer) do
    do_evaluate(document, pointer)
  end

  defp unescape(pointer) do
    String.replace(pointer, ["~1", "~0"], fn
      "~1" -> "/"
      "~0" -> "~"
    end)
  end

  defp do_evaluate(document, "/" <> _str = pointer) do
    # JSON String Representation
    do_evaluate(document, pointer, :json_str)
  end

  defp do_evaluate(document, "#" <> _str = pointer) do
    # URI Fragment Identifier Representation
    do_evaluate(document, pointer, :uri)
  end

  defp do_evaluate(_document, _pointer) do
    {:error, "Invalid JSON pointer syntax that not represented starts with `#` or `/`"}
  end

  defp do_evaluate(document, "#" <> str, mode) do
    do_evaluate(document, str, mode)
  end

  defp do_evaluate(document, "/" <> str, mode) do
    do_evaluate(document, str, mode)
  end

  defp do_evaluate(document, str, mode) when is_bitstring(str) do
    ref_tokens = String.split(str, "/")
    do_evaluate(document, ref_tokens, mode)
  end

  defp do_evaluate(document, [], _mode) do
    document
  end

  defp do_evaluate(document, [ref_token | res], mode) when is_list(document) do
    with {index, ""} <- Integer.parse(ref_token),
         value when is_map(value) or is_list(value) <- Enum.at(document, index) do
      do_evaluate(value, res, mode)
    else
      {_, other} when other != "" ->
        nil

      :error ->
        nil

      value ->
        value
    end
  end

  defp do_evaluate(document, [ref_token | res], :json_str) when is_map(document) do
    inner = Map.get(document, unescape(ref_token))
    if inner != nil, do: do_evaluate(inner, res, :json_str), else: nil
  end

  defp do_evaluate(document, [ref_token | res], :uri) when is_map(document) do
    decoded_ref_token = ref_token |> unescape() |> URI.decode_www_form()
    inner = Map.get(document, decoded_ref_token)
    if inner != nil, do: do_evaluate(inner, res, :uri), else: nil
  end
end
