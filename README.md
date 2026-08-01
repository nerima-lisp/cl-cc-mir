# cl-cc-mir

The machine-level intermediate representation for the
[cl-cc](https://github.com/nerima-lisp/cl-cc) Common Lisp compiler — the form
register allocation, native code generation and object emission consume.

This repository also provides `cl-cc-target`: target machine descriptions
(the ABI and ISA facts instruction selection, register allocation and the
encoders read — x86-64, AArch64, RISC-V 64 and WebAssembly 32), formerly its
own `cl-cc-target` repo. The two systems are always co-consumed as a pair, so
they now live together here; each keeps its own ASDF system name and package
(`cl-cc-mir`/`:cl-cc/mir` and `cl-cc-target`/`:cl-cc/target`), and neither
depends on the other.

Both are pure `:cl` leaves: `:depends-on` is empty for each, and `t/` asserts
no other cl-cc package is loaded alongside them.

## Usage

```lisp
(asdf:load-system "cl-cc-mir")
(asdf:load-system "cl-cc-target")
(cl-cc/target:find-target :x86-64)
```

## Development

```sh
nix develop
nix flake check
```

## License

MIT
