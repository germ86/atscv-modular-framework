\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{atscv}[2026/05/03 v0.2.0 ATS-safe modular CV framework]
\RequirePackage{iftex}
\ifLuaTeX\else
  \ClassError{atscv}{atscv requires LuaLaTeX}{Please compile with LuaLaTeX.}
\fi
\LoadClass{article}
\RequirePackage{xcolor}
\RequirePackage{geometry}
\RequirePackage{fontspec}
\RequirePackage[bidi=basic]{babel}
\RequirePackage{atscv-base}
\RequirePackage{atscv-utils}
\RequirePackage{atscv-cv}
\RequirePackage{atscv-letter}
\RequirePackage{atscv-schema-general}
\RequirePackage{atscv-color-blue}
\RequirePackage{atscv-style-modern}
\RequirePackage{atscv-layout-standard}
\RequirePackage{atscv-lang-en}
