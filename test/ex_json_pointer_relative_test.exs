defmodule ExJSONPointer.RelativeTest do
  use ExUnit.Case

  # test data from https://datatracker.ietf.org/doc/html/draft-bhutton-relative-json-pointer-00#section-5.1
  @data %{"foo" => ["bar", "baz"], "highly" => %{"nested" => %{"objects" => true}}}

  # test data from https://opis.io/json-schema/2.x/pointers.html
  @data2 %{
    "name" => "some product",
    "price" => 10.5,
    "features" => [
      "easy to use",
      %{
        "name" => "environment friendly",
        "url" => "http://example.com"
      }
    ],
    "info" => %{
      "onStock" => true
    },
    "a/b" => "a"
  }

  test "start from the value is an item within an array" do
    assert ExJSONPointer.Relative.resolve(@data, "/foo/1", "0") == "baz"
    assert ExJSONPointer.Relative.resolve(@data, "/foo/1", "1/0") == "bar"
    assert ExJSONPointer.Relative.resolve(@data, "/foo/1", "0-1") == "bar"
    assert ExJSONPointer.Relative.resolve(@data, "/foo/1", "2/highly/nested/objects") == true
    assert ExJSONPointer.Relative.resolve(@data, "/foo/1", "0#") == 1
    assert ExJSONPointer.Relative.resolve(@data, "/foo/1", "0-1#") == 0
    assert ExJSONPointer.Relative.resolve(@data, "/foo/1", "1#") == "foo"
  end

  test "start from the value is object" do
    assert ExJSONPointer.Relative.resolve(@data, "/highly/nested", "0/objects") == true
    assert ExJSONPointer.Relative.resolve(@data, "/highly/nested", "1/nested/objects") == true
    assert ExJSONPointer.Relative.resolve(@data, "/highly/nested", "2/foo/0") == "bar"
    assert ExJSONPointer.Relative.resolve(@data, "/highly/nested", "0#") == "nested"
    assert ExJSONPointer.Relative.resolve(@data, "/highly/nested", "1#") == "highly"
  end

  test "start from a normal value" do
    assert ExJSONPointer.Relative.resolve(@data2, "/price", "0") == 10.5
    assert ExJSONPointer.Relative.resolve(@data2, "/price", "0#") == "price"
    assert ExJSONPointer.Relative.resolve(@data2, "/price", "1") == @data2
    assert ExJSONPointer.Relative.resolve(@data2, "/price", "1#") == {:error, "not found"}
    assert ExJSONPointer.Relative.resolve(@data2, "/price", "1/name") == "some product"
    assert ExJSONPointer.Relative.resolve(@data2, "/price", "1/info") == %{"onStock" => true}
    assert ExJSONPointer.Relative.resolve(@data2, "/price", "1/info/onStock") == true
    assert ExJSONPointer.Relative.resolve(@data2, "/price", "1/a~1b") == "a"
    assert ExJSONPointer.Relative.resolve(@data2, "/price", "1/inexstent/path") == {:error, "not found"}
    assert ExJSONPointer.Relative.resolve(@data2, "/price", "2") == {:error, "not found"}
  end

  test "start from a value of an object in an array" do
    assert ExJSONPointer.Relative.resolve(@data2, "/features/1/url", "0") == "http://example.com"
    assert ExJSONPointer.Relative.resolve(@data2, "/features/1/url", "0#") == "url"
    assert ExJSONPointer.Relative.resolve(@data2, "/features/1/url", "1#") == 1
    assert ExJSONPointer.Relative.resolve(@data2, "/features/1/url", "1/name") == "environment friendly"
    assert ExJSONPointer.Relative.resolve(@data2, "/features/1/url", "2#") == "features"
    assert ExJSONPointer.Relative.resolve(@data2, "/features/1/url", "2/0") == "easy to use"
    assert ExJSONPointer.Relative.resolve(@data2, "/features/1/url", "1-1") == "easy to use"
    assert ExJSONPointer.Relative.resolve(@data2, "/features/1/url", "2/0#") == 0
    assert ExJSONPointer.Relative.resolve(@data2, "/features/1/url", "3") == @data2
    assert ExJSONPointer.Relative.resolve(@data2, "/features/1/url", "3/price") == 10.5
    assert ExJSONPointer.Relative.resolve(@data2, "/features/1/url", "3/info/onStock") == true
    assert ExJSONPointer.Relative.resolve(@data2, "/features/1/url", "3/info/inexstent2/path") == {:error, "not found"}
    assert ExJSONPointer.Relative.resolve(@data2, "/features/1/url", "3#") == {:error, "not found"}
    assert ExJSONPointer.Relative.resolve(@data2, "/features/1/url", "4") == {:error, "not found"}
  end
end
