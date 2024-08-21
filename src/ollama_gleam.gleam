import gleam/dynamic.{field, int, list, string}
import gleam/json.{type DecodeError, decode}

pub type OllamaResponse {
  Embeddings(embeddings: List(Int))
}

pub fn call_ollama(path: String, options: String) {
  "this was embedded"
}

pub fn embedding(input: String) -> Result(OllamaResponse, DecodeError) {
  let embeddins_response_decoder =
    dynamic.decode1(Embeddings, field("embeddings", of: list(int)))

  let result = ""

  decode(from: result, using: embeddins_response_decoder)
}
