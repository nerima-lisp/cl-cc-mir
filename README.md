# cl-cc-mir

The machine-level intermediate representation for the
[cl-cc](https://github.com/nerima-lisp/cl-cc) Common Lisp compiler — the form
register allocation, native code generation and object emission consume.

A pure `:cl` leaf: `:depends-on` is empty, and `t/` asserts no other cl-cc
package is loaded alongside it.

## Usage

```lisp
(asdf:load-system "cl-cc-mir")
```

## Development

```sh
nix develop
nix flake check
```

## License

MIT
