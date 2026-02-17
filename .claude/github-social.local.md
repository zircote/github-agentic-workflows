---
# Image generation provider
provider: svg

# SVG-specific settings
svg_style: illustrated

# Dark mode support
# false = light mode only, true = dark mode only, both = generate both variants
dark_mode: both

# Output settings
output_path: .github/social-preview.svg
dimensions: 1280x640
include_text: true
colors: auto

# README infographic settings
infographic_output: .github/readme-infographic.svg
infographic_style: hybrid

# Upload to repository
upload_to_repo: false
---

# GitHub Social Plugin Configuration

This configuration was created by `/github-social:setup`.

## Provider: SVG (Illustrated)

Claude generates organic SVG graphics with hand-drawn aesthetic and warm colors. No API key required.

## Dark Mode: Both

Generates both light and dark variants:
- `.github/social-preview.svg` (light)
- `.github/social-preview-dark.svg` (dark)

## Commands

- `/social-preview` — Generate social preview image
- `/readme-enhance` — Add badges and infographic to README
- `/github-social:all` — Run all skills in sequence
- `/github-social:setup` — Reconfigure these settings
