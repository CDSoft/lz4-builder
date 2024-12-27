# Lz4 builder

This repository just bundles [Lz4](https://github.com/lz4/lz4) into a Git project.
It provides a [bang](https://github.com/CDSoft/bang) file to cross compile lz4 for Linux, MacOS and Windows.

# Usage

```
$ bang
```

This generates the Ninja file for your platform (the provided Ninja file was generated for Linux).

```
$ ninja help
Distribution of lzip binaries for Linux, MacOS and Windows.

This Ninja build file will compile and install lz4 for Linux, MacOS and Windows

Targets:
  help      show this help message
  compile   Build Lz4 binaries for the host only
  all       Build Lz4 archives for Linux, MacOS and Windows
  install   install Lz4 in PREFIX or ~/.local
  clean     clean generated files
```

# Installation of Lz4

To install Lz4 in `~/.local/bin`:

```
$ ninja install
```

Or in a custom directory (e.g. `/path/bin`):

```
$ PREFIX=/path/ ninja install
```

# Cross compilation of Lz4

You'll need [Zig](https://ziglang.org).

```
$ ninja all
```

Archives for all supported platforms are created in `.build`.
