# ========================================
# Zsh Script for Functions
# ========================================

# Remove any existing alias before defining the function
unalias imageresize 2>/dev/null
unalias imageconvertrgb 2>/dev/null
unalias imagegrayscale 2>/dev/null

# Image processing functions using ImageMagick

# Resize images function - supports file, folder, or pattern
imageresize() {
    local usage="Usage: imageresize [target] [quality] [size]
    target: file, directory, or pattern (default: current directory)
    quality: 1-100 (default: 100)
    size: WIDTHxHEIGHT (default: 2048x2048)

  Examples:
    imageresize                        # resize all JPGs in current dir
    imageresize image.jpg              # resize single file
    imageresize ./photos               # resize all JPGs in folder
    imageresize \"*.png\" 100 1920x1920   # resize PNGs matching pattern"
    
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        echo "$usage"
        return 0
    fi
    
    local target="${1:-.}"
    local quality="${2:-100}"
    local size="${3:-2048x2048}"
    
    # Validate quality
    if [[ ! "$quality" =~ ^[0-9]+$ ]] || [[ "$quality" -lt 1 ]] || [[ "$quality" -gt 100 ]]; then
        echo "Error: Quality must be between 1-100"
        return 1
    fi
    
    if [[ -f "$target" ]]; then
        echo "Resizing file: $target (${size}, ${quality}% quality)"
        magick mogrify -filter Lanczos -resize "$size" -quality "$quality" "$target"
    elif [[ -d "$target" ]]; then
        echo "Resizing all JPG/JPEG files in: $target (${size}, ${quality}% quality)"
        find "$target" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) -exec magick mogrify -filter Lanczos -resize "$size" -quality "$quality" {} \;
    else
        echo "Resizing files matching: $target (${size}, ${quality}% quality)"
        magick mogrify -filter Lanczos -resize "$size" -quality "$quality" $target
    fi
}

# Convert image color profile to sRGB
imageconvertrgb() {
    local usage="Usage: imageconvertrgb [target] [method]
    target: file, directory, or pattern (default: current directory)
    method: strip/convert/assign (default: convert)
      strip: just remove color profiles
      convert: convert colorspace to sRGB (preserves appearance)
      assign: assign sRGB profile without conversion"
    
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        echo "$usage"
        return 0
    fi
    
    local target="${1:-.}"
    local method="${2:-convert}"
    
    if [[ -f "$target" ]]; then
        echo "Processing file: $target (method: $method)"
        case "$method" in
            "strip")
                magick mogrify +profile "*" "$target"
                ;;
            "convert")
                # Convert to sRGB while preserving appearance
                magick mogrify -intent perceptual -colorspace sRGB "$target"
                ;;
            "assign")
                # Just assign sRGB profile without conversion
                magick mogrify +profile "*" -profile /System/Library/ColorSync/Profiles/sRGB\ Profile.icc "$target" 2>/dev/null || magick mogrify +profile "*" "$target"
                ;;
        esac
    elif [[ -d "$target" ]]; then
        echo "Processing all image files in directory: $target (method: $method)"
        case "$method" in
            "strip")
                find "$target" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.tiff" -o -iname "*.tif" \) -exec magick mogrify +profile "*" {} \;
                ;;
            "convert")
                find "$target" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.tiff" -o -iname "*.tif" \) -exec magick mogrify -intent perceptual -colorspace sRGB {} \;
                ;;
            "assign")
                find "$target" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.tiff" -o -iname "*.tif" \) -exec magick mogrify +profile "*" -profile /System/Library/ColorSync/Profiles/sRGB\ Profile.icc {} \; 2>/dev/null || find "$target" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.tiff" -o -iname "*.tif" \) -exec magick mogrify +profile "*" {} \;
                ;;
        esac
    else
        echo "Processing files matching pattern: $target (method: $method)"
        case "$method" in
            "strip")
                magick mogrify +profile "*" $target
                ;;
            "convert")
                magick mogrify -intent perceptual -colorspace sRGB $target
                ;;
            "assign")
                magick mogrify +profile "*" -profile /System/Library/ColorSync/Profiles/sRGB\ Profile.icc $target 2>/dev/null || magick mogrify +profile "*" $target
                ;;
        esac
    fi
}

# Convert color images to grayscale
imagegrayscale() {
    local usage="Usage: imagegrayscale [target] [method]
    target: file, directory, or pattern (default: current directory)
    method: rec709/rec601/average/colorspace (default: rec709)
      rec709: perceptual luma weights matching sRGB/HDTV (recommended, best default)
      rec601: perceptual luma weights matching older SDTV standard
      average: simple average of R, G and B channels
      colorspace: convert to the linear Gray colorspace (can look darker/lower contrast)"

    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        echo "$usage"
        return 0
    fi

    local target="${1:-.}"
    local method="${2:-rec709}"

    if [[ -f "$target" ]]; then
        echo "Converting file to grayscale: $target (method: $method)"
        case "$method" in
            "rec709")
                magick mogrify -grayscale Rec709Luminance "$target"
                ;;
            "rec601")
                magick mogrify -grayscale Rec601Luminance "$target"
                ;;
            "average")
                magick mogrify -grayscale Average "$target"
                ;;
            "colorspace")
                magick mogrify -colorspace Gray "$target"
                ;;
        esac
    elif [[ -d "$target" ]]; then
        echo "Converting all image files in directory to grayscale: $target (method: $method)"
        case "$method" in
            "rec709")
                find "$target" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.tiff" -o -iname "*.tif" \) -exec magick mogrify -grayscale Rec709Luminance {} \;
                ;;
            "rec601")
                find "$target" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.tiff" -o -iname "*.tif" \) -exec magick mogrify -grayscale Rec601Luminance {} \;
                ;;
            "average")
                find "$target" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.tiff" -o -iname "*.tif" \) -exec magick mogrify -grayscale Average {} \;
                ;;
            "colorspace")
                find "$target" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.tiff" -o -iname "*.tif" \) -exec magick mogrify -colorspace Gray {} \;
                ;;
        esac
    else
        echo "Converting files matching pattern to grayscale: $target (method: $method)"
        case "$method" in
            "rec709")
                magick mogrify -grayscale Rec709Luminance $target
                ;;
            "rec601")
                magick mogrify -grayscale Rec601Luminance $target
                ;;
            "average")
                magick mogrify -grayscale Average $target
                ;;
            "colorspace")
                magick mogrify -colorspace Gray $target
                ;;
        esac
    fi
}