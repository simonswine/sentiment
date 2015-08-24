defmodule Hackernews do
  @base_url 'https://hacker-news.firebaseio.com'

  def get_id(id) do
    get_json_from_url "#{@base_url}/v0/item/#{id}.json"
  end

  def get_top do
    get_json_from_url "#{@base_url}/v0/topstories.json"
  end

  def get_json_from_url(url) do
    HTTPotion.get(url).body
      |> Poison.Parser.parse!
  end

  def process_top do
    Hackernews.get_top
      |> iterate
  end

  def iterate([head | tail]) do
    Hackernews.process_story(head)
    Hackernews.iterate(tail)
  end

  def iterate_comments([head | tail]) do
    Hackernews.process_comment(head)
    Hackernews.iterate_comments(tail)
  end

  def iterate_comments(head) do
    Hackernews.process_comment(head)
  end

  def process_story(id) do
    IO.puts "Getting #{id}"

    story = Hackernews.get_id(id)
    Map.get(story, "kids")
      |> iterate_comments
  end

  def process_comment(comment_id) do
    get_sentiment(
      "https://hacker-news.firebaseio.com/v0/item/#{comment_id}"
    )
  end

  def get_sentiment(url) do
    resp = HTTPotion.get(
      "http://access.alchemyapi.com/calls/url/URLGetTextSentiment?url=#{url}&apikey=1ecee1905f971b1fcbc20c8da4d9f7496969a0b1&outputMode=json",
      [timeout: 10000]
    ).body |> Poison.Parser.parse!
    IO.puts inspect resp
  end


end
