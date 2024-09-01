import gleam/io
import gleam/json
import gleam/list
import gleam/option
import gleam/string
import gleeunit
import gleeunit/should
import ollama_gleam
import simplifile

pub fn main() {
  gleeunit.main()
}

pub fn embeddings_response_decoder_test() {
  let assert Ok(json) = simplifile.read("test/embeddings_response.json")
  let assert Ok(embeddings_response) =
    json.decode(json, ollama_gleam.embeddings_response_decoder)

  embeddings_response.embeddings
  |> list.is_empty
  |> should.be_false
}

pub fn idk_yet_test() {
  let input =
    ollama_gleam.EmbeddingsRequest(
      model: "nomic-embed",
      input: ["my_things"],
      keep_alive: option.None,
      truncate: option.None,
      options: option.None,
    )

  let res = io.debug(ollama_gleam.embeddings_request(input))

  res.body
  |> string.contains("keep_alive")
  |> should.be_true
}
