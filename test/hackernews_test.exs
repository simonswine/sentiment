Code.require_file "test_helper.exs", __DIR__

defmodule FakeResponse do
  defstruct body: "{}", status_code: 200
end

defmodule HackernewsTest do
  use ExUnit.Case, async: false
  import Mock

  test "gets id" do
    with_mock HTTPotion,
        [get: fn(_url) -> %FakeResponse{body: '{"test":"123"}'}  end] do
      res = Hackernews.get_id(1)
      assert called HTTPotion.get("https://hacker-news.firebaseio.com/v0/item/1.json")
      assert res == %{"test" => "123"}
    end
  end

  test "gets top news" do
    with_mock HTTPotion,
        [get: fn(_url) -> %FakeResponse{body: '[1,2,3]'}  end] do
      res = Hackernews.get_top
      assert called HTTPotion.get("https://hacker-news.firebaseio.com/v0/topstories.json")
      assert res == [1,2,3]
    end
  end
end
