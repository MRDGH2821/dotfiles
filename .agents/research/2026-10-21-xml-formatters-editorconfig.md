# XML formatters and this repository's EditorConfig

Researched on 2026-10-21 against primary project documentation/source.

## Repository baseline

The root [`.editorconfig`](../../.editorconfig) applies UTF-8, LF, final newline, two-space indentation, and trailing-whitespace trimming to XML files. `quote_type = double` is a project-specific key, not a standard EditorConfig property.
The project uses Oxfmt 0.73.0 ([`mise.toml`](../../mise.toml), [`.oxfmtrc.json`](../../.oxfmtrc.json)), but its documented file formats do not include XML. [EditorConfig supported pairs](https://spec.editorconfig.org/index.html#supported-pairs); [Oxfmt formats](https://oxc.rs/docs/guide/usage/formatter/language-support) <!-- rumdl-disable-line existing-relative-links -->

## Options

- **Best CLI fit: Prettier with `@prettier/plugin-xml`.** Prettier reads `.editorconfig` and maps `end_of_line`, `indent_style`, `indent_size`/`tab_width`, and `max_line_length`.
  Its docs describe UTF-8 output and a final newline as defaults. Set the plugin's `xmlQuoteAttributes: "double"` to match this repo's nonstandard `quote_type`.
  The XML plugin formats XML and defaults to strict whitespace sensitivity, which avoids changing significant text whitespace. Requires Node.js and both packages.
  [Prettier configuration](https://prettier.io/docs/configuration#editorconfig), [plugin README](https://github.com/prettier/plugin-xml)

- **Closest option-driven CLI match: `xmlformatter` (Python).** Its Python API supports two-space indentation, a space indent character, UTF-8 output, and a final newline.
  Its CLI exposes indentation and encoding flags but no documented final-newline switch, and it does not read EditorConfig automatically.
  Its default correction rules normalize text and mixed-content whitespace, which can change XML text values; use its preservation/correction options only after reviewing samples.
  [Project README and options](https://github.com/pamoller/xmlformatter)

- **libxml2 includes `xmllint --format`, but it is risky for canonical output.** `XMLLINT_INDENT="  "` sets two-space indentation and `--encode UTF-8` sets output encoding.
  It does not read EditorConfig or expose controls for LF, final newline, or trailing whitespace. The manual warns formatting has never worked reliably, especially without a DTD, and is fundamentally broken.
  [xmllint manual](https://gnome.pages.gitlab.gnome.org/libxml2/xmllint.html)

- **Simple standalone option-based formatter: XMLStarlet.** `xml format --indent-spaces 2 --encode utf-8` mirrors indentation and encoding, but its format command has no EditorConfig support or documented controls for LF, final newline, or trailing whitespace. [XMLStarlet format guide](https://xmlstar.sourceforge.net/doc/UG/ch04s05.html)

- **IDE-only alternatives:** IntelliJ IDEA/ReSharper provide XML-specific EditorConfig settings; Red Hat's VS Code XML formatter uses VS Code's `editor.insertSpaces` and `editor.tabSize`, plus its own XML options.
  These suit editor formatting, not a portable CLI CI task. [JetBrains XML EditorConfig](https://www.jetbrains.com/help/resharper/2024.2/EditorConfig_XML_XmlCodeStylePageSchema.html), [VS Code XML formatting](https://github.com/redhat-developer/vscode-xml/blob/main/docs/Formatting.md)

## Recommendation

For this repo's two-space/LF settings, Prettier plus the XML plugin is the best match for CI formatting.
Keep the plugin's default strict whitespace mode unless the XML text is known to be whitespace-insensitive.
Oxfmt alone does not format standalone XML. No option found safely maps every EditorConfig property while normalizing arbitrary XML text.