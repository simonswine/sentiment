
defmodule Hackernews do
  def get_id(id) do
    HTTPotion.get("https://hacker-news.firebaseio.com/v0/item/#{id}.json?print=pretty").body
      |> Poison.Parser.parse!
  end


  def get_top do
    HTTPotion.get("https://hacker-news.firebaseio.com/v0/topstories.json").body
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

  def process_comment(comment) do
    IO.puts get_id(comment)

  end

  def get_sentiment(url) do
    HTTPotion.get("http://access.alchemyapi.com/calls/url/URLGetTextSentiment?url=#{url}&apikey=1ecee1905f971b1fcbc20c8da4d9f7496969a0b1")    
  end

end
