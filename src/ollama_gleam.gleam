import gleam/dynamic.{field, float, int, list, string}
import gleam/http/request
import gleam/httpc
import gleam/json.{array as jarr, object, string as jstring}
import gleam/result
import gleam/string

pub type EmbeddingsRequest {
  SingleInput(model: String, input: String)
  MultipleInput(model: String, input: List(String))
}

pub type EmbeddingsResponse {
  SingleResponse(
    model: String,
    embeddings: List(List(Float)),
    total_duration: Float,
    load_duration: Float,
    promp_eval_count: Int,
  )
  MultipleResponse(model: String, embeddings: List(List(Float)))
}

fn get_ollama_url() -> String {
  "http://localhost:11434/api/"
}

pub fn call_ollama(path: String, input: String) -> Result(String, OllamaError) {
  let assert Ok(base_req) = request.to(get_ollama_url() <> path)
  let req =
    request.set_header(base_req, "Content-Type", "application/json")
    |> request.set_body(input)
    |> request.set_method(http.Post)

  httpc.send(req)
  |> result.map_error(fn(_) { Comm })
  |> result.map(fn(x) { x.body })
}

fn get_decoder(embeddings_request: EmbeddingsRequest) {
  case embeddings_request {
    MultipleInput(_, _) ->
      dynamic.decode2(
        MultipleResponse,
        field("model", of: string),
        field("embeddings", of: list(list(float))),
      )
    SingleInput(_, _) ->
      dynamic.decode5(
        SingleResponse,
        field("model", of: string),
        field("embeddings", of: list(list(float))),
        field("total_duration", of: float),
        field("load_duration", of: float),
        field("promp_eval_count", of: int),
      )
  }
}

fn map_decoder(res: Result(t, json.DecodeError)) -> Result(t, OllamaError) {
  result.map_error(res, fn(_) { DecodingResp })
}

fn encode_embed_request(input: EmbeddingsRequest) -> String {
  case input {
    MultipleInput(m, i) ->
      object([#("model", jstring(m)), #("input", jarr(i, of: jstring))])
    SingleInput(m, i) ->
      object([#("model", jstring(m)), #("input", jstring(i))])
  }
  |> json.to_string
}

pub type OllamaError {
  Comm
  DecodingResp
}

pub fn embedding(
  embeddings_request: EmbeddingsRequest,
) -> Result(EmbeddingsResponse, OllamaError) {
  encode_embed_request(embeddings_request)
  |> call_ollama("embed", _)
  |> result.try(fn(s) {
    get_decoder(embeddings_request)
    |> json.decode(s, _)
    |> map_decoder
  })
}
