# Janet Keyword Args (KArgs)

Kargs aim to make cli arguments function like Janet arguments.
This follows a few simple rules.

1. If we're not expecting a value, we try to parse a flag.
2. A flag is defined as either a short flag or a long flag.
   A short flag can be `-a` or `-abcd` (this becomes an `:abcd` keyword, for use as flags).
   A long flag can be `--abcd=value` (where value is parsed as in 3)
   or `--abcd` (in which case the value is expected to be the next argument).
3. If a flag is matched, flag semantics (as above) take over.
   Otherwise, or if we expect a value, we parse it using the Janet parser.
   If the parser outputs a symbol or fails to parse the value, we turn it into an as-is string.

And that's it.
Have fun!

Note that this library is not stable, I reserve the right to change it whenever until 1.0.0 is tagged.
This is because I'm going to pull a hehecat and use it in production to see if it feels right or not.

## Bugs
Technically, I use `parse` and not `parse-all`.
I probably should use `parse-all` and also check for `length`.
I don't care though.
Test condition: "1 hi" should result in "1 hi" but results in 1.
