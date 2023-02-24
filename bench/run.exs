data = %{
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


Benchee.run(
  %{
    ":ex_json_pointer implementions(self)" => fn -> ExJSONPointer.evaluate(data, "/a/b2/c2/0") end,
    ":odgn_json_pointer implementions" => fn -> JSONPointer.get(data, "/a/b2/c2/0") end,
    #":json_pointer implementions" => fn -> JSONPointer.resolve(data, "/a/b2/c2/0") end,
  },
  time: 10,
  memory_time: 2,
  print: %{
    fast_warning: false
  }
)

