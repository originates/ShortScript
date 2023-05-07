#!/bin/bash
# A tool to optimize code for AI prompting.
# Author: github.com/richkmls
# Date: 5/7/2023
# Usage:
#	0. In ubuntu, add the path to this script as a custom key binding
# 	1. Select a JavaScript/Python code that you want to shorten.
# 	2. Press Win+C to copy a markdown codeblock with the shortened code.
# 	3. Paste the codeblock wherever you want.

# Copy the primary selection to the clipboard
xclip -selection primary -o | xclip -selection clipboard -i

# Read the clipboard content into a variable
clipboardText=$(xclip -selection clipboard -o)

# Initialize an empty string for the new text
newText=""

# Initialize a variable to keep track of whether we are in a multi-line comment
inComment=false

# Loop through each line of the clipboard text
while read -r line; do

    # Remove any leading or trailing whitespace and tabs from the line
    line=$(echo "$line" | sed 's/^[ \t]*//;s/[ \t]*$//')

    # If the line is empty or a comment, skip it
    if [[ -z "$line" || "$line" =~ ^(#|//) ]]; then
        continue
    fi

    # Check if the line contains triple quotes indicating a multi-line comment
    if [[ $line =~ .*\"\"\".* ]]; then
        # Check if there is another set of triple quotes on the same line
        if [[ $line =~ .*\"\"\".*\"\"\".* ]]; then
            # This is a single line comment using triple quotes syntax
            continue
        else
            # Set inComment to true and skip this line since it is part of a multi-line comment
            inComment=true 
            continue
        fi
    fi

    # Split the line by // and # and keep everything before it using awk to match the pattern 
    # and print the first field while ignoring instances of "//" that are part of a URL 
    # and ignoring instances of "#" or "//" that are between single or double quotation marks
    linePart=$(echo "$line" | awk '{sub(/[^:]\/\//,""); sub(/([^"'"'"'])#([^"'"'"'])/,"\\1\\2")}1')

    # Append the line part to the new text and trim any white space at both ends using sed command 
    newText+=$(echo "$linePart" | sed 's/^[ \t]*//;s/[ \t]*$//')
    newText+=$'\n'

done <<< "$clipboardText"

# Add "\`\`\`" and a newline at the beginning of the string
newText="\`\`\`"$'\n'"$newText"

# Add a "\`\`\`" at the end of the string
newText+=$"\`\`\`"

# Replace the clipboard with the new text using xclip command 
echo "$newText" | xclip -selection clipboard
