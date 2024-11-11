#!/bin/bash

# Function to convert HTML to markdown while preserving structure
convert_page() {
    local input_file=$1
    local output_file=$2
    local title=$(grep -A1 "<title>" "$input_file" | tail -n1 | sed 's/<[^>]*>//g' || echo "")

    # Create markdown with front matter
    echo "---" > "$output_file"
    echo "title: \"$title\"" >> "$output_file"
    echo "draft: false" >> "$output_file"
    echo "---" >> "$output_file"

    # Convert HTML to markdown while preserving HTML elements
    pandoc -f html+raw_html -t markdown+raw_html --wrap=none \
        "$input_file" | \
        sed 's/\/img\//\/static\/img\//g' >> "$output_file"
}

# Process main sections
for section in about blog classes contact; do
    if [ -f ~/backup/$section/index.html ]; then
        mkdir -p content/$section
        convert_page ~/backup/$section/index.html content/$section/_index.md
    fi
done

# Process portfolio items
if [ -f ~/backup/portfolio/index.html ]; then
    mkdir -p content/portfolio
    convert_page ~/backup/portfolio/index.html content/portfolio/_index.md
fi

for work in ~/backup/portfolio/work*/index.html; do
    if [ -f "$work" ]; then
        work_dir=$(basename $(dirname "$work"))
        mkdir -p "content/portfolio/$work_dir"
        convert_page "$work" "content/portfolio/$work_dir/_index.md"
    fi
done
