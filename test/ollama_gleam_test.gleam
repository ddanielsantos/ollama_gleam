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

pub fn embeddings_request_test() {
  let input =
    ollama_gleam.EmbeddingsRequest(
      model: "nomic-embed",
      input: ["my_things"],
      keep_alive: option.None,
      truncate: option.None,
      options: option.None,
    )

  let res = ollama_gleam.embeddings_request(input)

  res.body
  |> string.contains("keep_alive")
  |> should.be_true
}

pub fn generate_request_test() {
  let input =
    ollama_gleam.GenerateRequest(
      model: "llama3.1:8b",
      context: option.None,
      format: option.None,
      images: option.None,
      keep_alive: option.None,
      options: option.None,
      prompt: "Why is the sky blue",
      raw: option.None,
      stream: option.Some(False),
      suffix: option.None,
      system: option.None,
      template: option.None,
    )

  let req = ollama_gleam.generate_request(input)

  req.body
  |> string.contains("prompt")
  |> should.be_true
}
