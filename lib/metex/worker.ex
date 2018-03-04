defmodule Metex.Worker do
  def temperature_of(location) do
    url_for(location)
    |> HTTPoison.get
    |> parse_response
    |> process(location)
  end

  defp process({:ok, temp}, location) do
    "#{location}: #{temp} C"
  end

  defp process(:error, location) do
    "#{location}: not found"
  end

  defp url_for(location) do
    "api.openweathermap.org/data/2.5/weather?q=#{URI.encode(location)}&appid=#{apikey()}"
  end

  defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    body
    |> JSON.decode!
    |> compute_temperature
  end

  defp parse_response(_) do
    :error
  end

  defp compute_temperature(json) do
    try do
      temp = (json["main"]["temp"] - 273.15)
             |> Float.round(1)
             {:ok, temp} 
    rescue
      _ -> :error
    end
  end

  defp apikey, do: "4d03e5482d785f56f2e8a0b6fac350a5"
end
