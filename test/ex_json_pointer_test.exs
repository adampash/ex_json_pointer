defmodule ExJSONPointerTest do
  use ExUnit.Case
  doctest ExJSONPointer

  @rfc6901_data %{
    "foo" => ["bar", "baz"],
    "" => 0,
    "a/b" => 1,
    "c%d" => 2,
    "e^f" => 3,
    "g|h" => 4,
    "i\\j" => 5,
    "k\"l" => 6,
    " " => 7,
    "m~n" => 8
  }

  @nesting_data %{
    "" => %{
      "a" => %{
        "b" => %{
          "c" => [1, 2, 3],
          "" => "empty string from empty token"
        }
      }
    },
    "a" => %{
      "b" => %{
        "c" => [1, 2, 3],
        "" => "empty string"
      },
      "b2" => %{
        "c2" => [
          %{"d2-1" => [4, 5, 6]},
          %{"d2-2" => "7"}
        ]
      }
    }
  }

  describe "JSON string representation" do
    test "rfc6901 data sample" do
      assert ExJSONPointer.resolve(@rfc6901_data, "") == @rfc6901_data
      assert ExJSONPointer.resolve(@rfc6901_data, "/foo") == ["bar", "baz"]
      assert ExJSONPointer.resolve(@rfc6901_data, "/foo/0") == "bar"
      assert ExJSONPointer.resolve(@rfc6901_data, "/") == 0
      assert ExJSONPointer.resolve(@rfc6901_data, "/a~1b") == 1
      assert ExJSONPointer.resolve(@rfc6901_data, "/c%d") == 2
      assert ExJSONPointer.resolve(@rfc6901_data, "/e^f") == 3
      assert ExJSONPointer.resolve(@rfc6901_data, "/g|h") == 4
      assert ExJSONPointer.resolve(@rfc6901_data, "/i\\j") == 5
      assert ExJSONPointer.resolve(@rfc6901_data, "/k\"l") == 6
      assert ExJSONPointer.resolve(@rfc6901_data, "/ ") == 7
      assert ExJSONPointer.resolve(@rfc6901_data, "/m~0n") == 8
    end

    test "nesting map" do
      assert ExJSONPointer.resolve(@nesting_data, "/a/b/4") == nil
      assert ExJSONPointer.resolve(@nesting_data, "/a/b/c/4") == nil
      assert ExJSONPointer.resolve(@nesting_data, "/a/b/c/unknown") == nil
      assert ExJSONPointer.resolve(@nesting_data, "/a/b/c/0") == 1

      assert ExJSONPointer.resolve(@nesting_data, "/a/b") == %{
               "c" => [1, 2, 3],
               "" => "empty string"
             }

      assert ExJSONPointer.resolve(@nesting_data, "//a/b") == %{
               "c" => [1, 2, 3],
               "" => "empty string from empty token"
             }

      assert ExJSONPointer.resolve(@nesting_data, "/a/b/") == "empty string"
    end

    test "inner map of list" do
      assert ExJSONPointer.resolve(@nesting_data, "/a/b2/c2/0/d2-1/0") == 4
      assert ExJSONPointer.resolve(@nesting_data, "/a/b2/c2/0/d2-1/1") == 5
      assert ExJSONPointer.resolve(@nesting_data, "/a/b2/c2/0/d2-1/2") == 6
      assert ExJSONPointer.resolve(@nesting_data, "/a/b2/c2/1/d2-2") == "7"
    end
  end

  describe "URI fragment identifier representation" do
    test "rfc6901 data sample" do
      assert ExJSONPointer.resolve(@rfc6901_data, "#") == @rfc6901_data
      assert ExJSONPointer.resolve(@rfc6901_data, "#/foo") == ["bar", "baz"]
      assert ExJSONPointer.resolve(@rfc6901_data, "#/foo/0") == "bar"
      assert ExJSONPointer.resolve(@rfc6901_data, "#/") == 0
      assert ExJSONPointer.resolve(@rfc6901_data, "#/a~1b") == 1
      assert ExJSONPointer.resolve(@rfc6901_data, "#/c%25d") == 2
      assert ExJSONPointer.resolve(@rfc6901_data, "#/e%5Ef") == 3
      assert ExJSONPointer.resolve(@rfc6901_data, "#/g%7Ch") == 4
      assert ExJSONPointer.resolve(@rfc6901_data, "#/i%5Cj") == 5
      assert ExJSONPointer.resolve(@rfc6901_data, "#/k%22l") == 6
      assert ExJSONPointer.resolve(@rfc6901_data, "#/%20") == 7
      assert ExJSONPointer.resolve(@rfc6901_data, "#/m~0n") == 8
    end

    test "nesting map" do
      assert ExJSONPointer.resolve(@nesting_data, "#/a/b/4") == nil
      assert ExJSONPointer.resolve(@nesting_data, "#/a/b/c/4") == nil
      assert ExJSONPointer.resolve(@nesting_data, "#/a/b/c/0") == 1

      assert ExJSONPointer.resolve(@nesting_data, "#/a/b") == %{
               "c" => [1, 2, 3],
               "" => "empty string"
             }

      assert ExJSONPointer.resolve(@nesting_data, "#a/b") == %{
               "c" => [1, 2, 3],
               "" => "empty string"
             }

      assert ExJSONPointer.resolve(@nesting_data, "##/a/b") == {
               :error, "invalid URI fragment identifier"
             }

      assert ExJSONPointer.resolve(@nesting_data, "#//a/b") == %{
               "c" => [1, 2, 3],
               "" => "empty string from empty token"
             }

      assert ExJSONPointer.resolve(@nesting_data, "#/a/b/") == "empty string"
    end

    test "inner map of list" do
      assert ExJSONPointer.resolve(@nesting_data, "#/a/b2/c2/0/d2-1/0") == 4
      assert ExJSONPointer.resolve(@nesting_data, "#/a/b2/c2/0/d2-1/1") == 5
      assert ExJSONPointer.resolve(@nesting_data, "#/a/b2/c2/0/d2-1/2") == 6
      assert ExJSONPointer.resolve(@nesting_data, "#/a/b2/c2/1/d2-2") == "7"
    end
  end

  test "invalid syntax" do
    assert ExJSONPointer.resolve(@nesting_data, "a/b") ==
             {:error, "invalid JSON pointer syntax that not represented starts with `#` or `/`"}
  end

  test "the ref token is exceeded the index of array" do
    assert ExJSONPointer.resolve(%{"a" => %{"b" => %{"c" => [1, 2, 3]}}}, "/a/b/c/0") == 1
    assert ExJSONPointer.resolve(%{"a" => %{"b" => %{"c" => [1, 2, 3]}}}, "/a/b/c/4") == nil
  end

  test "the ref token size is exceeded the depth of input json" do
    assert ExJSONPointer.resolve(%{"a" => %{"b" => %{"c" => [1, 2, 3]}}}, "/a/b/c///") == nil
  end
end
