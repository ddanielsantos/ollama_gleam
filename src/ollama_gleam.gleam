import gleam/dynamic.{field, int, list, string, float}
import gleam/json.{object, string as jstring, array as jarr}
import gleam/http/request
import gleam/httpc
import gleam/result
import gleam/string

pub type EmbeddingsRequest {
  SingleInput(model: String, input: String)
  MultipleInput(model: String, input: List(String))
}

pub type EmbeddingsResponse {
  SingleResponse(model: String, embeddings: List(List(Float)), total_duration: Float, load_duration: Float, promp_eval_count: Int)
  MultipleResponse(model: String, embeddings: List(List(Float)))
}

fn get_ollama_url() -> String {
  "http://localhost:11434/api/"
}

pub fn call_ollama(path: String, input: String) -> Result(String, OllamaError) {
  let assert Ok(base_req) = request.to(string.append(get_ollama_url(), path))
  let req = request.set_header(base_req, "Content-Type", "application/json")
  |> request.set_body(input)

  use resp <- result.try(httpc.send(req), fn(_) {Error(Comm)})

  case resp {
    Ok(r) -> Ok(r.body)
    Error(_) -> Error(Comm)
  }
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

fn map_decoder(res: Result(t, json.DecodeError)) -> Result(t, OllamaError) {
  result.map_error(res, fn(_) {
    DecodingResp
  })
}

fn encode_embed_request(input: EmbeddingsRequest) -> String {
  case input {
    MultipleInput(m, i) -> object([
      #("model", jstring(m)),
      #("input", jarr(i,  of: jstring)),
    ])
    SingleInput(m, i) -> object([
      #("model", jstring(m)),
      #("input", jstring(i)),
    ])
  } |> json.to_string
}

pub type OllamaError {
  Comm
  DecodingResp
}

pub fn embedding(embeddings_request: EmbeddingsRequest) -> Result(EmbeddingsResponse, OllamaError) {
  let input = encode_embed_request(embeddings_request)
  let resp = call_ollama("embed", input)

  case resp {
    Error(e) -> Error(e)
    Ok(resp) -> {
      let dec = get_decoder(embeddings_request)
      let dec_resp = json.decode(resp, dec)
      map_decoder(dec_resp)
    }
  }
}
