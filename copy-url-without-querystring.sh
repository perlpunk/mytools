#!/bin/bash

# Some webaps like Redmine always append unwanted things to the query string
# when commenting on a ticket. If you want to give someone else the ticket
# url, you usually want to remove that stuff.
# Just call this script and your current CTRL-C selection will be put
# into your primary X selector and the clipboard, but with everying after
# the ? stripped.

current=$(xsel -o)
new="${current/\?*}"

echo -n "$new" | xsel -i -b
echo -n "$new" | xsel -i -p
