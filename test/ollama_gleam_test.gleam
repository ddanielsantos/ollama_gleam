import gleam/list
import gleam/result.{try}
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
  use res <- result.try(ollama_gleam.embedding(req))

  res.embeddings
  |> list.is_empty
  |> should.be_false

  Ok(res)
}
