# FDO DJ opas

Musiikin soitto-ohjeet FDO:n kilpailuihin.

## Dependencies

- LuaLaTex
- Fonts: Roboto & Roboto Mono
- [GhostScript](https://ghostscript.com/about/index.html)

```shell
brew install ghostscript mactex pandoc
brew install --cask font-roboto font-roboto-mono
```

## Convert tikz to PDF

```shell
lualatex katkelma.tex
```

## Convert document to Word

```shell
pandoc -s "FDO DJ opas.tex" -o "FDO DJ opas.docx"
```
