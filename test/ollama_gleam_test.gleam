import gleam/json
import gleam/list
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
