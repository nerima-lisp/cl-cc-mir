{
  description = "cl-cc AST node types and protocol (ast-children, ast-bound-names)";

  inputs = {
    # nixos-unstable, not nixpkgs-unstable: it advances only after the NixOS
    # release tests pass, so it is less likely to land a broken build.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Pinned to a release tag. A bare `github:nerima-lisp/cl-weave` follows
    # that repository's default branch, so an upstream push to main would
    # break this repository's CI without warning. This used to be a
    # `flake = false` source tree handed to the runner through an environment
    # variable; it is a normal flake input now, which is what lets ASDF find
    # cl-weave through CL_SOURCE_REGISTRY like any other dependency.
    cl-weave = {
      url = "github:nerima-lisp/cl-weave/v1.4.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      cl-weave,
      treefmt-nix,
      ...
    }:
    let
      systems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

      # CL_SOURCE_REGISTRY for the test, coverage and dev environments.
      sourceRegistry = "${cl-weave}//:${self}//";

      # Single source of truth for the package version: the `:version` form in
      # cl-cc-mir.asd. A release only ever edits the .asd file and every Nix
      # package (default + docs) follows automatically. Nix regexes are
      # whole-string anchored and `.` never spans newlines, so the version is
      # extracted line-by-line rather than with one multi-line match.
      version =
        let
          lines = nixpkgs.lib.splitString "\n" (builtins.readFile ./cl-cc-mir.asd);
          versionLine = builtins.head (
            builtins.filter (line: builtins.match "[[:space:]]*:version \"[^\"]*\"" line != null) lines
          );
        in
        builtins.head (builtins.match "[[:space:]]*:version \"([^\"]*)\"" versionLine);

      # treefmt drives `nix fmt` and the `checks.<system>.formatting` gate.
      # Scope is Nix only: nixfmt (RFC-style) is a zero-footgun, low-diff
      # formatter, whereas YAML formatters mangle the GitHub Actions `on:`
      # key and Markdown reformatting would churn the whole docs tree.
      treefmtEval = forAllSystems (
        system:
        treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} {
          projectRootFile = "flake.nix";
          programs.nixfmt.enable = true;
        }
      );
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        rec {
          cl-cc-mir = pkgs.sbcl.buildASDFSystem {
            pname = "cl-cc-mir";
            inherit version;
            src = self;
            systems = [ "cl-cc-mir" ];
          };
          default = cl-cc-mir;

          # Rendered documentation site (Material for MkDocs).
          # Build fully offline: Material for MkDocs bundles all of its assets,
          # so no network access is required inside the Nix sandbox. --strict
          # promotes broken links and unlisted pages to build failures.
        }
      );

      # `nix fmt` entry point.
      formatter = forAllSystems (system: treefmtEval.${system}.config.build.wrapper);

      # Granularity lives here, NOT in extra GitHub Actions jobs: `nix flake
      # check` evaluates each attribute as its own derivation, in parallel,
      # with build caching. Add a check here rather than a job in ci.yml.
      checks = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default =
            pkgs.runCommand "cl-cc-mir-tests"
              {
                nativeBuildInputs = [
                  pkgs.sbcl
                  pkgs.coreutils
                ];
                CL_SOURCE_REGISTRY = sourceRegistry;
              }
              ''
                export HOME="$TMPDIR/home"
                mkdir -p "$HOME" "$out"
                timeout 120 sbcl --script ${self}/run-tests.lisp
                touch "$out/passed"
              '';

          orphan-tests =
            pkgs.runCommand "cl-cc-mir-orphan-tests"
              {
                nativeBuildInputs = [
                  pkgs.sbcl
                  pkgs.coreutils
                ];
                CL_SOURCE_REGISTRY = sourceRegistry;
              }
              ''
                export HOME="$TMPDIR/home"
                mkdir -p "$HOME" "$out"
                PROJECT_ROOT=${self} ${pkgs.sbcl}/bin/sbcl --noinform --script /dev/stdin <<'LISP'
                (require :asdf)

                (defun tree-files (directory)
                  (append (uiop:directory-files directory)
                          (mapcan #'tree-files
                                  (remove-if
                                   (lambda (subdirectory)
                                     (member (pathname-name subdirectory)
                                             '(".git" ".jj")
                                             :test #'string=))
                                   (uiop:subdirectories directory)))))

                (defun test-lisp-file-p (pathname)
                  (and (string-equal (or (pathname-type pathname) "") "lisp")
                       (search "test" (or (pathname-name pathname) "")
                               :test #'char-equal)))

                (defun source-component-paths (component)
                  (if (typep component 'asdf:source-file)
                      (list (namestring
                             (truename (asdf:component-pathname component))))
                      (mapcan #'source-component-paths
                              (asdf:component-children component))))

                (let* ((root (truename (uiop:getenv "PROJECT_ROOT")))
                       (test-root (truename (merge-pathnames "t/" root)))
                       (asd-files (remove-if-not
                                   (lambda (pathname)
                                     (string-equal (or (pathname-type pathname) "") "asd"))
                                   (tree-files root)))
                       (test-files (remove-if-not #'test-lisp-file-p
                                                  (tree-files test-root))))
                  (unless test-files
                    (error "No test files found under t/"))
                  (dolist (asd-file asd-files)
                    (asdf:load-asd asd-file))
                  (let* ((asd-paths (mapcar (lambda (pathname)
                                              (namestring (truename pathname)))
                                            asd-files))
                         (test-systems
                           (remove-if-not
                            (lambda (system)
                              (let ((name (asdf:component-name system))
                                    (source-file (asdf:system-source-file system)))
                                (and source-file
                                     (uiop:string-suffix-p name "/test")
                                     (member
                                      (namestring
                                       (truename source-file))
                                      asd-paths
                                      :test #'string=))))
                            (mapcar #'asdf:find-system (asdf:registered-systems))))
                         (selected-paths
                           (mapcar (lambda (pathname)
                                     (namestring (truename pathname)))
                                   test-files))
                         (component-paths
                           (remove-duplicates
                            (mapcan #'source-component-paths test-systems)
                            :test #'string=))
                         (matched-paths (intersection selected-paths component-paths
                                                     :test #'string=))
                         (orphans (set-difference selected-paths component-paths
                                                  :test #'string=)))
                    (format t "Selected test files: ~d~%" (length selected-paths))
                    (format t "Matched test file components: ~d~%" (length matched-paths))
                    (dolist (orphan orphans)
                      (format *error-output* "Orphan test file: ~a~%" orphan))
                    (when orphans
                      (error "Found ~d orphan test file(s)" (length orphans)))))
                LISP
                touch "$out/passed"
              '';

          # Fails `nix flake check` when any tracked file is unformatted,
          # turning the formatter into an enforced CI gate.
          formatting = treefmtEval.${system}.config.build.check self;

        }
      );

      apps = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          test = pkgs.writeShellApplication {
            name = "cl-cc-mir-test";
            runtimeInputs = [
              pkgs.sbcl
              pkgs.coreutils
            ];
            text = ''
              export CL_SOURCE_REGISTRY="${sourceRegistry}"
              exec timeout 120 sbcl --script ${self}/run-tests.lisp
            '';
          };
        in
        {
          default = {
            type = "app";
            program = "${test}/bin/cl-cc-mir-test";
          };
          test = {
            type = "app";
            program = "${test}/bin/cl-cc-mir-test";
          };
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = [ pkgs.sbcl ];
            CL_SOURCE_REGISTRY = sourceRegistry;
          };
        }
      );
    };
}
