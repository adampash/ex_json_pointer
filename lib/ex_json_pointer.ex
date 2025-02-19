defmodule ExJSONPointer do
  @external_resource readme = Path.join([__DIR__, "../README.md"])
  @moduledoc File.read!(readme)

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
  * `nil` - when the pointer does not resolve to a value
  * `term()` - the resolved value
  * `{:error, String.t()}` - when there is an error in pointer syntax
  """
  @type result :: nil | term() | {:error, String.t()}

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
  """
  @spec resolve(document, pointer) :: result
  def resolve(document, ""), do: document
  def resolve(document, "#"), do: document

  def resolve(document, pointer)
      when is_map(document) and is_bitstring(pointer) do
    do_resolve(document, pointer)
  end

  # Unescapes the reference token by replacing ~1 with / and ~0 with ~
  defp unescape(pointer) do
    String.replace(pointer, ["~1", "~0"], fn
      "~1" -> "/"
      "~0" -> "~"
    end)
  end

  defp do_resolve(document, "/" <> _pointer_str = pointer) do
    # JSON String Representation
    resolve_json_str(document, pointer)
  end

  defp do_resolve(document, "#" <> _pointer_str = pointer) do
    # URI Fragment Identifier Representation
    resolve_uri_fragment(document, pointer)
  end

  defp do_resolve(_document, _pointer) do
    {:error, "invalid JSON pointer syntax that not represented starts with `#` or `/`"}
  end

  defp resolve_json_str(document, ""), do: document
  defp resolve_json_str(document, "/" <> _ = pointer_str) do
    start_process(document, pointer_str, "json_str")
  end

  defp resolve_uri_fragment(document, "#"), do: document
  defp resolve_uri_fragment(document, "#" <> _ = pointer_str) do
    case URI.new(pointer_str) do
      {:ok, uri} ->
        start_process(document, uri.fragment, "uri_fragment")
      {:error, _} ->
        {:error, "invalid URI fragment identifier"}
    end
  end

  # Starts processing the pointer by splitting it into reference tokens
  defp start_process(document, "", _mode), do: document
  defp start_process(document, input, mode) when is_bitstring(input) do
    case String.split(input, "/") do
      ["" | ref_tokens] ->
        process(document, ref_tokens, mode)
      other ->
        process(document, other, mode)
    end
  end

  # Process reference tokens recursively to find the target value
  defp process(value, [], _mode) do
    value
  end

  # Handle array access with numeric indices
  defp process(document, [ref_token | rest], mode) when is_list(document) do
    with {index, ""} <- Integer.parse(ref_token),
         value when is_map(value) or is_list(value) <- Enum.at(document, index) do
      process(value, rest, mode)
    else
      {_, other} when other != "" ->
        nil
      :error ->
        nil
      value ->
        value
    end
  end

  # Handle object access for JSON String Representation
  defp process(document, [ref_token | rest], "json_str" = mode) when is_map(document) do
    inner = Map.get(document, unescape(ref_token))
    if inner != nil, do: process(inner, rest, mode), else: nil
  end

  # Handle object access for URI Fragment Identifier Representation
  defp process(document, [ref_token | rest], "uri_fragment" = mode) when is_map(document) do
    decoded_ref_token = ref_token |> unescape() |> URI.decode_www_form()
    inner = Map.get(document, decoded_ref_token)
    if inner != nil, do: process(inner, rest, mode), else: nil
  end

  # Handle case when we've reached a leaf node but still have reference tokens
  defp process(value, _ref_tokens, _mode)
    when not is_list(value)
    when not is_map(value) do
    nil
  end
end
