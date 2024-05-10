{
  description = "CLIO";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = {
    self,
    flake-parts,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-darwin" "x86_64-darwin"];
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: let
        buildInputs = with pkgs; [
          gnumake
          micromamba
          texlive.combined.scheme-full
          automake
          autoconf
          libtool
          hwloc
          cmake
          ninja
          pkg-config
          gfortran
          gfortran.cc
          openblas
        ];
        env =
          if system == "x86_64-linux"
          then
            pkgs.buildFHSUserEnv
            {
              inherit buildInputs;
              name = "clio-env";

              targetPkgs = _: [
                pkgs.micromamba
              ];

              profile = ''
                set -e
                eval "$(micromamba shell hook --shell=posix)"
                export MAMBA_ROOT_PREFIX=${builtins.getEnv "PWD"}/.mamba
                micromamba create -q --name clio --file env.yaml
                micromamba activate clio
                set +e
              '';
            }
            .env
          else
            pkgs.mkShell {
              inherit buildInputs;
              name = "llm-profiler";
              DIRENV_LOG_FORMAT = "";
              shellHook = ''
                ########################################
                # Micromamba
                ########################################

                MICROMAMBA_ENV_NAME="llm-profiler"
                PWD=$(git rev-parse --show-toplevel)
                eval "$(micromamba shell hook --shell=posix)"
                export PROJECT_DIR=$PWD
                export MAMBA_ROOT_PREFIX=$PWD/.mamba
                # check environment already exists
                # check if env.yaml has been updated
                if [ ! -d $MAMBA_ROOT_PREFIX/envs/$MICROMAMBA_ENV_NAME ]; then
                  echo -e "\033[0;34mCreating environment\033[0m"
                  rm -rf $MAMBA_ROOT_PREFIX/envs/$MICROMAMBA_ENV_NAME
                  micromamba create -q --name $MICROMAMBA_ENV_NAME python=3.11 -y
                  # save last date of environment creation
                  date > $MAMBA_ROOT_PREFIX/envs/$MICROMAMBA_ENV_NAME/.created
                fi
                if [ -f $MAMBA_ROOT_PREFIX/envs/$MICROMAMBA_ENV_NAME/.created ]; then
                  echo -e "\033[0;34mCreating environment\033[0m"
                  rm -rf $MAMBA_ROOT_PREFIX/envs/$MICROMAMBA_ENV_NAME
                  micromamba create -q --name $MICROMAMBA_ENV_NAME python=3.11 -y
                  date > $MAMBA_ROOT_PREFIX/envs/$MICROMAMBA_ENV_NAME/.created
                fi

                echo -e "\033[0;34mActivating environment\033[0m"
                micromamba activate $MICROMAMBA_ENV_NAME

                VENV_DIR="./.venv"
                echo "Checking if virtual environment exists"
                if [ ! -d "$VENV_DIR" ]; then
                  mkdir -p "$VENV_DIR"
                  python -m venv "$VENV_DIR" --system-site-packages
                fi

                source "$VENV_DIR/bin/activate"

              '';
            };
      in {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [
            (final: prev: {})
          ];
          config = {};
        };
        devShells.default = env;
      };
    };
}
