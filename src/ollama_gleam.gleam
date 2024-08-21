import gleam/dynamic.{field, int, list, string, float}
import gleam/json.{type DecodeError, decode}

pub type EmbeddingsRequest {
  SingleInput(model: String, input: String)
  MultipleInput(model: String, input: String)
}

pub type EmbeddingsResponse {
  SingleResponse(model: String, embeddings: List(List(Float)), total_duration: Float, load_duration: Float, promp_eval_count: Int)
  MultipleResponse(model: String, embeddings: List(List(Float)))
}

pub fn call_ollama(path: String, options: String) {
  "this was embedded"
}

fn get_decoder(embeddings_request: EmbeddingsRequest) {
  case embeddings_request {
    MultipleInput(_, _) -> dynamic.decode2(
      MultipleResponse,
      field("model", of: string),
      field("embeddings", of: list(list(float))),
    )
    SingleInput(_, _) -> dynamic.decode5(
      SingleResponse,
      field("model", of: string),
      field("embeddings", of: list(list(float))),
      field("total_duration", of: float),
      field("load_duration", of: float),
      field("promp_eval_count", of: int),
    )
  }
}

pub fn embedding(embeddings_request: EmbeddingsRequest) -> Result(EmbeddingsResponse, DecodeError) {
  let decoder = get_decoder(embeddings_request)

  let result = ""

  decode(from: result, using: decoder)
}
