defmodule ExJSONPointer do
  @external_resource readme = Path.join([__DIR__, "../README.md"])
  @moduledoc File.read!(readme)
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  @typedoc """
  The JSON document to be processed, must be a map.
  """
  @type document :: map()

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

  defdelegate resolve(document, start_json_point, relative), to: __MODULE__.Relative
end
