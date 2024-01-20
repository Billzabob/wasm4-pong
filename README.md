# WASM-4 Pong

A game written in WebAssembly Text for the [WASM-4](https://wasm4.org) fantasy console.

## Play It!

[Try it out here!](https://billzabob.github.io/wasm4-pong/)

## Building

#### Requirements
- [wabt](https://github.com/WebAssembly/wabt?tab=readme-ov-file) for `wat2wasm`
- [wasm4](https://wasm4.org/docs/getting-started/setup) for `wat`


Build the cart by running:

```shell
wat2wasm main.wait -o build/cart.wasm
```

Then run it with:

```shell
w4 run build/cart.wasm
```

Bundle it with

```shell
wasm4_pong git:(main) ./w4 bundle build/cart.wasm --title "WASM-4 Pong" --html index.html
```

For more info about setting up WASM-4, see the [quickstart guide](https://wasm4.org/docs/getting-started/setup?code-lang=wat#quickstart).

## Links

- [Documentation](https://wasm4.org/docs): Learn more about WASM-4.
- [Snake Tutorial](https://wasm4.org/docs/tutorials/snake/goal): Learn how to build a complete game
  with a step-by-step tutorial.
- [GitHub](https://github.com/aduros/wasm4): Submit an issue or PR. Contributions are welcome!
