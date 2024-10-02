#!/bin/bash
set -eo pipefail

USAGE="Usage: $0 [OPTIONS]

Compile PDF and process with Ghostscript.

OPTIONS: All options are optional
    -h | --help
        Display these instructions.

    -c | --clean
        Clean temporary files before building.

    -n | --no-gs
        Skip Ghostscript compression step.

    -v | --verbose
        Display commands being executed.
"

# Print a message with green color
print_green() {
    printf "\e[1;49;32m%s\e[0m\n" "$1"
}

# Print a message with magenta color
print_magenta() {
    printf "\e[1;49;35m%s\e[0m\n" "$1"
}

# Print a message with red color
print_red() {
    printf "\e[1;49;31m%s\e[0m\n" "$1"
}

# Print a message with yellow color
print_yellow() {
    printf "\e[1;49;33m%s\e[0m\n" "$1"
}

# Print an error and exit the program
print_error_and_exit() {
    print_red "ERROR: $1"
    # use exit code if given as argument, otherwise default to 1
    exit "${2:-1}"
}

# Check platform
case "$(uname -s)" in
    "Darwin")
        PLATFORM="mac"
        ;;
    "MINGW"*)
        PLATFORM="windows"
        ;;
    *)
        PLATFORM="linux"
        ;;
esac

if [ "$PLATFORM" = windows ]; then
    GHOSTSCRIPT="gswin64c.exe"
else
    GHOSTSCRIPT="gs"
fi

# Get absolute path to repo root
REPO_ROOT=$(git rev-parse --show-toplevel || (cd "$(dirname "${BASH_SOURCE[0]}")" && pwd))
OUTPUT_DIR="$REPO_ROOT/out"

FILENAME="FDO DJ opas"
TEX_FILE="$REPO_ROOT/$FILENAME.tex"
PDF_FILE="$REPO_ROOT/$FILENAME.pdf"
PDF_FILE_WITH_DATE="$REPO_ROOT/$FILENAME $(date "+%Y.%m.%d").pdf"
PDFA_DEFS_FILE="$REPO_ROOT/PDFA_def.ps"

init_options() {
    COMPRESS=true
    while [ $# -gt 0 ]; do
        case "$1" in
            -h | --help)
                echo "$USAGE"
                exit 1
                ;;
            -c | --clean)
                print_magenta "Cleaning files..."
                git -C "$REPO_ROOT" clean -ndx
                git -C "$REPO_ROOT" clean -fdx
                ;;
            -n | --no-gs)
                COMPRESS=false
                ;;
            -v | --verbose)
                set -x
                ;;
        esac
        shift
    done
}

init_options "$@"

cd "$REPO_ROOT"

mkdir -p "$OUTPUT_DIR"

if [ -z "$(command -v lualatex)" ]; then
    print_error_and_exit "lualatex command not found in path"
fi

COMPILE_COMMAND=(
    lualatex
    --shell-escape
    --halt-on-error
    --interaction=nonstopmode
    --file-line-error
    --synctex=1
    --output-directory="$OUTPUT_DIR"
)

print_magenta "Compiling with LuaLaTex..."
"${COMPILE_COMMAND[@]}" "$TEX_FILE"
mv "$OUTPUT_DIR/$FILENAME.pdf" "$PDF_FILE"
print_green "$PDF_FILE"

if [ "$PLATFORM" = mac ]; then
    open "$PDF_FILE"
fi

if [ "$COMPRESS" = true ]; then
    if [ -n "$(command -v $GHOSTSCRIPT)" ]; then
        print_magenta "Compressing PDF with ghostscript..."
        $GHOSTSCRIPT \
            -dBATCH \
            -dNOPAUSE \
            -dNOSAFER \
            -dPDFA=2 \
            -dPDFACompatibilityPolicy=1 \
            -dCompatibilityLevel=1.7 \
            -dPrinted=false \
            -dAutoRotatePages=/None \
            -dDetectDuplicateImages=true \
            -dEmbedAllFonts=true \
            -dPDFSETTINGS=/prepress \
            -sDEVICE=pdfwrite \
            -sColorConversionStrategy=UseDeviceIndependentColor \
            -sProcessColorModel=DeviceRGB \
            -sOutputFile="$PDF_FILE_WITH_DATE" \
            "$PDFA_DEFS_FILE" \
            "$PDF_FILE"

        print_green "$PDF_FILE_WITH_DATE"
    else
        print_yellow "ghostscript not found, skipping..."
    fi
fi
