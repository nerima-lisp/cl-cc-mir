# Glossary

## ir

- Definition: Machine-level SSA control-flow IR: values, constants, instructions, blocks, functions, and modules, with builders, type and effect analysis, control-flow analyses, and printers.
- Package: `cl-cc/mir/ir`
- Key types: `mir-value`, `mir-const`, `mir-inst`, `mir-block`, `mir-function`, `mir-module`
- Key functions: `mir-make-function`, `mir-new-block`, `mir-emit`, `mir-rpo`, `mir-dominators`, `mir-propagate-types`
- Other contexts: None.

## target

- Definition: Describes target word size, registers, calling conventions, legal operations, and target features, and provides predefined target descriptions through a registry.
- Package: `cl-cc/mir/target`
- Key types: `target-desc`
- Key functions: `make-target-desc`, `register-target`, `find-target`, `target-allocatable-regs`
- Other contexts: None.
