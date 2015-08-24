Code.require_file "test_helper.exs", __DIR__

defmodule FakeResponse do
  defstruct body: "{}", status_code: 200
end

defmodule HackernewsTest do
  use ExUnit.Case, async: false
  import :meck

  setup_all do
    new(HTTPotion)
    on_exit fn -> unload end
    :ok
  end

  def fake_response(url) do
    cond do
      Regex.match?(~r/\/1\.json$/, url) -> %FakeResponse{
        body: '{"id":1,"kids":[4,5],"title":"Story 1","type":"story"}'
      }
      Regex.match?(~r/\/2\.json$/, url) -> %FakeResponse{
        body: '{"id":2,"kids":[6],"title":"Story 2","type":"story"}'
      }
      Regex.match?(~r/\/3\.json$/, url) -> %FakeResponse{
        body: '{"id":3,"kids":[],"title":"Story 3","type":"story"}'
      }
      Regex.match?(~r/topstories\.json$/, url) -> %FakeResponse{
        body: '[1,2,3]'
      }
    end
  end

  test "gets id" do
    expect(HTTPotion, :get, fn("https://hacker-news.firebaseio.com/v0/item/1.json") -> %FakeResponse{body: '{"test":"123"}'} end)
    assert validate(HTTPotion)
    assert Hackernews.get_id(1) == %{"test" => "123"}
  end

  test "gets top news" do
    expect(HTTPotion, :get, fn("https://hacker-news.firebaseio.com/v0/topstories.json") -> %FakeResponse{body: '[1,2,3]'} end)
    assert validate(HTTPotion)
    assert Hackernews.get_top == [1,2,3]
  end

  test "process top news" do
    expect(HTTPotion, :get, fn(url) -> fake_response(url) end)
#    expect(HTTPotion, :get, fn("https://hacker-news.firebaseio.com/v0/item/1.json") -> %FakeResponse{body: '{"id":1,"kids":[4,5],"title":"Story 1","type":"story"}'} end)
#    expect(HTTPotion, :get, fn("https://hacker-news.firebaseio.com/v0/item/2.json") -> %FakeResponse'} end)
#    expect(HTTPotion, :get, fn("https://hacker-news.firebaseio.com/v0/item/3.json") -> %FakeResponse{body: '{"id":3,"kids":[],"title":"Story 3","type":"story"}'} end)
    assert validate(HTTPotion)
    assert Hackernews.process_top == [1,2,3]
  end
end
