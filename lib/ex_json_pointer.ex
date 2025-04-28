defmodule ExJSONPointer do
  @external_resource readme = Path.join([__DIR__, "../README.md"])
  @moduledoc File.read!(readme)
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  @typedoc """
  The JSON document to be processed, must be a map.
  """
  @type document :: map() | list()

  @typedoc """
  The JSON Pointer string that follows RFC 6901 specification.
  Can be either a JSON String Representation (starting with '/') or
  a URI Fragment Identifier Representation (starting with '#').
  """
  @type pointer :: String.t()

  @typedoc """
  The result of resolving a JSON Pointer:
  * `term()` - the resolved value
  * `{:error, String.t()}` - when there is an error in pointer syntax or value not found
  """
  @type result :: term() | {:error, String.t()}

  @doc """
  Resolve the JSON document with the given JSON Pointer to find the accompanying value.

  The pointer can be either:
  - An empty string ("") or "#" to reference the whole document
  - A JSON String Representation starting with "/"
  - A URI Fragment Identifier Representation starting with "#"

  ## Examples

      iex> doc = %{"foo" => %{"bar" => "baz"}}
      iex> ExJSONPointer.resolve(doc, "/foo/bar")
      "baz"
      iex> ExJSONPointer.resolve(doc, "/foo/baz")
      {:error, "not found"}
      iex> ExJSONPointer.resolve(doc, "##foo")
      {:error, "invalid JSON pointer syntax"}
  """
  @spec resolve(document, pointer) :: result
  defdelegate resolve(document, pointer), to: __MODULE__.RFC6901

  @doc """
  Resolve a relative JSON pointer from a starting position within a JSON document.

  This function implements the Relative JSON Pointer specification as described in
  [draft-bhutton-relative-json-pointer-00](https://datatracker.ietf.org/doc/html/draft-bhutton-relative-json-pointer-00).

  A relative JSON pointer consists of:
  - A non-negative integer (prefix) that indicates how many levels up to traverse
  - An optional index manipulation (+N or -N) for array elements
  - An optional JSON pointer to navigate from the referenced location

  ## Parameters
  - `document`: The JSON document to be processed
  - `start_json_pointer`: A JSON pointer that identifies the starting location within the document
  - `relative`: The relative JSON pointer to evaluate from the starting location

  ## Examples

      iex> data = %{"foo" => ["bar", "baz"], "highly" => %{"nested" => %{"objects" => true}}}
      iex> ExJSONPointer.resolve(data, "/foo/1", "0")
      "baz"
      iex> ExJSONPointer.resolve(data, "/foo/1", "1/0")
      "bar"
      iex> ExJSONPointer.resolve(data, "/foo/1", "0-1")
      "bar"
      iex> ExJSONPointer.resolve(data, "/foo/1", "2/highly/nested/objects")
      true
      iex> ExJSONPointer.resolve(data, "/foo/1", "0#")
      1
  """
  @spec resolve(document, pointer, String.t()) :: result
  defdelegate resolve(document, start_json_pointer, relative), to: __MODULE__.Relative
end
