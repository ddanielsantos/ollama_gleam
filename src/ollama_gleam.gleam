import gleam/dynamic
import gleam/http
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/json
import gleam/option

fn get_ollama_url() -> String {
  "http://localhost:11434/api/"
}

pub type OllamaOptions {
  OllamaOptions(
    numa: option.Option(Bool),
    num_ctx: option.Option(Float),
    num_batch: option.Option(Float),
    num_gpu: option.Option(Float),
    main_gpu: option.Option(Float),
    low_vram: option.Option(Bool),
    f16_kv: option.Option(Bool),
    logits_all: option.Option(Bool),
    vocab_only: option.Option(Bool),
    use_mmap: option.Option(Bool),
    use_mlock: option.Option(Bool),
    embedding_only: option.Option(Bool),
    num_thread: option.Option(Float),
    num_keep: option.Option(Float),
    seed: option.Option(Float),
    num_predict: option.Option(Float),
    top_k: option.Option(Float),
    top_p: option.Option(Float),
    tfs_z: option.Option(Float),
    typical_p: option.Option(Float),
    repeat_last_n: option.Option(Float),
    temperature: option.Option(Float),
    repeat_penalty: option.Option(Float),
    presence_penalty: option.Option(Float),
    frequency_penalty: option.Option(Float),
    mirostat: option.Option(Float),
    mirostat_tau: option.Option(Float),
    mirostat_eta: option.Option(Float),
    penalize_newline: option.Option(Bool),
    stop: option.Option(List(String)),
  )
}

fn json_list_string(ls: List(String)) -> json.Json {
  json.array(ls, of: json.string)
}

fn json_ollama_options(options: OllamaOptions) -> json.Json {
  json.object([
    #("numa", json.nullable(options.numa, of: json.bool)),
    #("num_ctx", json.nullable(options.num_ctx, of: json.float)),
    #("num_batch", json.nullable(options.num_batch, of: json.float)),
    #("num_gpu", json.nullable(options.num_gpu, of: json.float)),
    #("main_gpu", json.nullable(options.main_gpu, of: json.float)),
    #("low_vram", json.nullable(options.low_vram, of: json.bool)),
    #("f16_kv", json.nullable(options.f16_kv, of: json.bool)),
    #("logits_all", json.nullable(options.logits_all, of: json.bool)),
    #("vocab_only", json.nullable(options.vocab_only, of: json.bool)),
    #("use_mmap", json.nullable(options.use_mmap, of: json.bool)),
    #("use_mlock", json.nullable(options.use_mlock, of: json.bool)),
    #("embedding_only", json.nullable(options.embedding_only, of: json.bool)),
    #("num_thread", json.nullable(options.num_thread, of: json.float)),
    #("num_keep", json.nullable(options.num_keep, of: json.float)),
    #("seed", json.nullable(options.seed, of: json.float)),
    #("num_predict", json.nullable(options.num_predict, of: json.float)),
    #("top_k", json.nullable(options.top_k, of: json.float)),
    #("top_p", json.nullable(options.top_p, of: json.float)),
    #("tfs_z", json.nullable(options.tfs_z, of: json.float)),
    #("typical_p", json.nullable(options.typical_p, of: json.float)),
    #("repeat_last_n", json.nullable(options.repeat_last_n, of: json.float)),
    #("temperature", json.nullable(options.temperature, of: json.float)),
    #("repeat_penalty", json.nullable(options.repeat_penalty, of: json.float)),
    #(
      "presence_penalty",
      json.nullable(options.presence_penalty, of: json.float),
    ),
    #(
      "frequency_penalty",
      json.nullable(options.frequency_penalty, of: json.float),
    ),
    #("mirostat", json.nullable(options.mirostat, of: json.float)),
    #("mirostat_tau", json.nullable(options.mirostat_tau, of: json.float)),
    #("mirostat_eta", json.nullable(options.mirostat_eta, of: json.float)),
    #(
      "penalize_newline",
      json.nullable(options.penalize_newline, of: json.bool),
    ),
    #("stop", json.nullable(options.stop, of: json_list_string)),
  ])
}

pub type EmbeddingsRequest {
  EmbeddingsRequest(
    model: String,
    input: List(String),
    truncate: option.Option(Bool),
    keep_alive: option.Option(String),
    options: option.Option(OllamaOptions),
  )
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

pub fn embeddings_request(
  embedddings_request: EmbeddingsRequest,
) -> Request(String) {
  let input =
    json.object([
      #("model", json.string(embedddings_request.model)),
      #("input", json.array(embedddings_request.input, of: json.string)),
      #("truncate", json.nullable(embedddings_request.truncate, of: json.bool)),
      #(
        "keep_alive",
        json.nullable(embedddings_request.keep_alive, of: json.string),
      ),
      #(
        "options",
        json.nullable(embedddings_request.options, of: json_ollama_options),
      ),
    ])
    |> json.to_string

  let assert Ok(base_req) = request.to(get_ollama_url() <> "embed")

  request.set_header(base_req, "Content-Type", "application/json")
  |> request.set_body(input)
  |> request.set_method(http.Post)
}

pub fn handle_embeddings_response(
  response: Response(String),
) -> Result(EmbeddingsResponse, json.DecodeError) {
  response.body
  |> json.decode(embeddings_response_decoder)
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
