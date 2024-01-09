# isaac_sim_rs

<p align="left">
  <a href="https://crates.io/crates/isaac_sim">                                        <img alt="crates.io" src="https://img.shields.io/crates/v/isaac_sim.svg"></a>
  <a href="https://github.com/AndrejOrsula/isaac_sim_rs/actions/workflows/rust.yml">   <img alt="Rust"      src="https://github.com/AndrejOrsula/isaac_sim_rs/actions/workflows/rust.yml/badge.svg"></a>
  <!-- <a href="https://github.com/AndrejOrsula/isaac_sim_rs/actions/workflows/docker.yml"> <img alt="Docker"    src="https://github.com/AndrejOrsula/isaac_sim_rs/actions/workflows/docker.yml/badge.svg"></a> -->
  <a href="https://codecov.io/gh/AndrejOrsula/isaac_sim_rs">                           <img alt="codecov"   src="https://codecov.io/gh/AndrejOrsula/isaac_sim_rs/branch/main/graph/badge.svg"></a>
</p>

Rust interface for NVIDIA [Isaac Sim](https://developer.nvidia.com/isaac-sim).

## Status

This project is in early development and is not ready for production use. Not all of the Isaac Sim API is currently exposed.

Documentation and examples are currently lacking but will be the focus once the crates are more stable.

## Overview

The workspace contains these packages:

- **[isaac_sim](isaac_sim):** Rust interface for Isaac Sim

## Dependencies

The complete list of dependencies can be found within [`Dockerfile`](Dockerfile).

## Instructions

### <a href="#-rust"><img src="https://rustacean.net/assets/rustacean-flat-noshadow.svg" width="16" height="16"></a> Rust

First, specify the path to existing Isaac Sim and Omniverse Kit installation directories via the following environment variables.

```bash
export ISAAC_SIM_PATH=/path/to/isaac_sim
export CARB_APP_PATH="$ISAAC_SIM_PATH/kit"
```

Add `isaac_sim` as a Rust dependency to your [`Cargo.toml`](https://doc.rust-lang.org/cargo/reference/manifest.html) manifest.

<!-- TODO[doc]: Update Cargo.toml dependency once the package can be reliably used from https://crates.io -->

```toml
[dependencies]
isaac_sim = { git = "https://github.com/AndrejOrsula/isaac_sim_rs.git" }
```

Note that the first build might take up to 50 minutes because OpenUSD will be automatically downloaded and compiled with the `vendored` feature enabled. The artifacts will be cached in `OUT_DIR` and reused for subsequent builds.

Alternatively, you can specify the path to an existing OpenUSD installation directory via the following environment variable.

```bash
export OPENUSD_PATH=/path/to/pxr/openusd
```

It is highly recommended to use `lld` or `mold` linker because `ld` might currently fail.

<details>
<summary><h3><a href="#-docker"><img src="https://www.svgrepo.com/show/448221/docker.svg" width="16" height="16"></a> Docker</h3></summary>

> To install [Docker](https://docs.docker.com/get-docker) on your system, you can run [`.docker/host/install_docker.bash`](.docker/host/install_docker.bash) to configure Docker with NVIDIA GPU support.
>
> ```bash
> .docker/host/install_docker.bash
> ```

By running the Docker container, you are implicitly agreeing to the [NVIDIA Omniverse EULA](https://docs.omniverse.nvidia.com/platform/latest/common/NVIDIA_Omniverse_License_Agreement.html). If you do not agree to this license agreement, do not use this container.

#### Build Image

In order to pull the base [Isaac Sim](https://catalog.ngc.nvidia.com/orgs/nvidia/containers/isaac-sim) image from the [NGC registry](https://ngc.nvidia.com), you must first create an account and [generate an API key](https://ngc.nvidia.com/setup/api-key) in order to authenticate with the registry.

```bash
docker login nvcr.io
```

To build a new Docker image from [`Dockerfile`](Dockerfile), you can run [`.docker/build.bash`](.docker/build.bash) as shown below.

```bash
.docker/build.bash ${TAG:-latest} ${BUILD_ARGS}
```

#### Run Container

To run the Docker container, you can use [`.docker/run.bash`](.docker/run.bash) as shown below.

```bash
.docker/run.bash ${TAG:-latest} ${CMD}
```

#### Run Dev Container

To run the Docker container in a development mode (source code mounted as a volume), you can use [`.docker/dev.bash`](.docker/dev.bash) as shown below.

```bash
.docker/dev.bash ${TAG:-latest} ${CMD}
```

As an alternative, VS Code users familiar with [Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers) can modify the included [`.devcontainer/devcontainer.json`](.devcontainer/devcontainer.json) to their needs. For convenience, [`.devcontainer/open.bash`](.devcontainer/open.bash) script is available to open this repository as a Dev Container in VS Code.

```bash
.devcontainer/open.bash
```

#### Join Container

To join a running Docker container from another terminal, you can use [`.docker/join.bash`](.docker/join.bash) as shown below.

```bash
.docker/join.bash ${CMD:-bash}
```

</details>

## Disclaimer

This project is not affiliated with NVIDIA Corporation.

## License

This project is dual-licensed to be compatible with the Rust project, under either the [MIT](LICENSE-MIT) or [Apache 2.0](LICENSE-APACHE) licenses.

## Contributing

Unless you explicitly state otherwise, any contribution intentionally submitted for inclusion in the work by you, as defined in the Apache-2.0 license, shall be dual licensed as above, without any additional terms or conditions.
