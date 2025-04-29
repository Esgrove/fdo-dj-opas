# FDO DJ opas

Musiikin soitto-ohjeet FDO:n kilpailuihin.

## Dependencies

Required:

- LuaLaTex
- Fonts: Roboto & Roboto Mono

Extra:

- [GhostScript](https://ghostscript.com/about/index.html)
- [Pandoc](https://pandoc.org)

Install on macOS:

```shell
brew install mactex ghostscript pandoc
brew install --cask font-roboto font-roboto-mono
```

## Compile document

Use the provided shell script:

```shell
./build.sh
# use `-h` or `--help` to check options:
./build.sh --help
```

## Convert tikz graphics to PDF

```shell
lualatex katkelma.tex
```

## Convert document to Word

```shell
pandoc -s "FDO DJ opas.tex" -o "FDO DJ opas.docx"
```
