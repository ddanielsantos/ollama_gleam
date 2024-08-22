import gleam/result
import gleeunit
import gleeunit/should
import ollama_gleam

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn hello_world_test() {
  let req =
    ollama_gleam.SingleInput("nomic-embed-text", "i want to see the sky")
  let response = ollama_gleam.embedding(req)

  response
  |> result.is_ok
  |> should.be_true

  Ok(response)
}
