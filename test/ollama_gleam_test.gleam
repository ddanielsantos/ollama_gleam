import gleam/result
import gleeunit
import gleeunit/should
import ollama_gleam

pub fn main() {
  gleeunit.main()
}

fn mock_ollama(_: String, _: String) -> Result(String, ollama_gleam.OllamaError) {
  Ok("{
    \"model\": \"nomic-embed-text\",
    \"embeddings\": [],
    \"total_duration\": 17870600,
    \"load_duration\": 1559300,
    \"prompt_eval_count\": 6
  }
")
}

pub fn hello_world_test() {
  let req =
    ollama_gleam.SingleInput("nomic-embed-text", "i want to see the sky")

  let response = ollama_gleam.embedding_internal_dont_use_or_youll_be_fired(req, mock_ollama)

  response
  |> result.is_ok
  |> should.be_true

  Ok(response)
}
