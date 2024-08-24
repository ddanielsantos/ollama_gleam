import gleam/dynamic
import gleam/http
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/json
import gleam/option
import gleam/result

pub type OllamaError {
  DecodingResp
}

pub type EmbeddingsResponse {
  EmbeddingsResponse(
    model: String,
    embeddings: List(List(Float)),
    total_duration: option.Option(Int),
    load_duration: option.Option(Int),
    prompt_eval_count: option.Option(Int),
  )
}

fn get_ollama_url() -> String {
  "http://localhost:11434/api/"
}

pub fn embeddings_request(model: String, input: List(String)) -> Request(String) {
  let input =
    json.object([
      #("model", json.string(model)),
      #("input", json.array(input, of: json.string)),
    ])
    |> json.to_string

  let assert Ok(base_req) = request.to(get_ollama_url() <> "embed")

  request.set_header(base_req, "Content-Type", "application/json")
  |> request.set_body(input)
  |> request.set_method(http.Post)
}

pub fn handle_embeddings_response(
  response: Response(String),
) -> Result(EmbeddingsResponse, OllamaError) {
  response.body
  |> json.decode(embeddings_response_decoder)
  |> result.map_error(fn(_) { DecodingResp })
}

pub fn embeddings_response_decoder(
  data: dynamic.Dynamic,
) -> Result(EmbeddingsResponse, List(dynamic.DecodeError)) {
  dynamic.decode5(
    EmbeddingsResponse,
    dynamic.field("model", dynamic.string),
    dynamic.field("embeddings", dynamic.list(dynamic.list(dynamic.float))),
    dynamic.optional_field("total_duration", dynamic.int),
    dynamic.optional_field("load_duration", dynamic.int),
    dynamic.optional_field("prompt_eval_count", dynamic.int),
  )(data)
}
