import gleam/io

fn call_ollama(path: String, options: String) {
  "this was embedded"
}

pub fn embedding(input: String) {
  call_ollama("embedding", input)
}
