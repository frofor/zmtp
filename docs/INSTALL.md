# Installation

## Prerequisites

- [Nix](https://nixos.org/download)
- [Git](https://git-scm.com/install)

## Installation

Clone repository:

```sh
git clone https://codeberg.org/frofor/zmtp.git
cd zmtp
```

Install dependencies:

```sh
nix develop
```

Build project:

```sh
zig build -Doptimize=ReleaseSafe
```

Binary will be created in `./zig-out/bin/zmtp`.
