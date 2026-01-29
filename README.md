# Hovering-annotation Extension For Quarto

Add floating annotation boxes with optional arrows and markers to your Quarto Revealjs presentations. Perfect for highlighting specific elements on slides with customizable colors, positioning, and animations.

To see the annotations in action see the [example slides](https://frederikaust.com/quarto-hovering-annotation) and compare to the [source file](example.qmd).

## Installing

```bash
quarto add crsh/hovering-annotation
```

This will install the extension under the `_extensions` subdirectory.
If you're using version control, you will want to check in this directory.

## Using

### Basic Usage

Add the filter to your document's YAML front matter:

```yaml
---
title: "My Presentation"
format: revealjs
filters:
  - hovering-annotation
---
```

Then use the shortcode in your slides:

```markdown
{{< hovering-annotation annotation="Your annotation text here" box-x="50" box-y="30" >}}
```

## Features

### Annotation Box

The annotation box is a floating text container that appears over your slide content.

**Parameters:**
- `annotation` (required): The text to display in the annotation box
- `box-x`: Horizontal position as percentage of viewport (default: `50`)
- `box-y`: Vertical position as percentage of viewport (default: `50`)
- `annotation-width`: Maximum width of the annotation box (default: `50%`)

**Example:**
```markdown
{{< hovering-annotation 
  annotation="This explains the concept" 
  box-x="65" 
  box-y="30" 
  annotation-width="35%" 
>}}
```

### Arrow Pointer

Add an arrow that points from the annotation box to a specific location on the slide.

**Parameters:**
- `head-x`: Horizontal position of arrow head as percentage of viewport
- `head-y`: Vertical position of arrow head as percentage of viewport

**Note:** Both `head-x` and `head-y` must be specified to display an arrow. Omit both to show only the annotation box.

**Example with arrow:**
```markdown
{{< hovering-annotation 
  annotation="Points to this element" 
  box-x="65" 
  box-y="30" 
  head-x="50" 
  head-y="22" 
>}}
```

**Example without arrow:**
```markdown
{{< hovering-annotation 
  annotation="Just a floating note" 
  box-x="20" 
  box-y="60" 
>}}
```

### Mark Indicator

Place a semi-transparent circular marker at any location on the slide.

**Parameters:**
- `mark-x`: Horizontal position of mark as percentage of viewport
- `mark-y`: Vertical position of mark as percentage of viewport
- `mark-width`: Width of the marker (default: `1.2em`)
- `mark-height`: Height of the marker (default: `1.2em`)
- `mark-opacity`: Opacity of the marker (default: `0.5`)

**Note:** Both `mark-x` and `mark-y` must be specified to display a marker.

**Example:**
```markdown
{{< hovering-annotation 
  annotation="Look here" 
  box-x="65" 
  box-y="30" 
  mark-x="50" 
  mark-y="22" 
  mark-width="2em"
  mark-height="2em"
  mark-opacity="0.7"
>}}
```

### Colors

The extension integrates with Quarto's brand color system. Define colors using the `brand` option in your front matter and reference them by number, or use direct hex colors.

#### Using Brand Colors

Define up to 9 annotation colors in your YAML front matter:

```yaml
---
brand:
  color:
    palette:
      annotation-color-1: "#3b82f6"  # Blue
      annotation-color-2: "#f97316"  # Orange
      annotation-color-3: "#10b981"  # Green
      annotation-color-4: "#8b5cf6"  # Purple
      annotation-color-5: "#ef4444"  # Red
---
```

Then reference them by number in your shortcodes:

```markdown
{{< hovering-annotation annotation="Blue annotation" color="1" >}}
{{< hovering-annotation annotation="Orange annotation" color="2" >}}
```

The brand colors are available as CSS variables (`--brand-annotation-color-1` through `--brand-annotation-color-9`) throughout your document for use in custom HTML/CSS.

#### Using Direct Colors

You can also specify colors directly using hex codes:

```markdown
{{< hovering-annotation annotation="Custom color" color="#ff6b6b" >}}
```

**Parameter:**
- `col`: Color number (1-9) or hex color code (default: `1`)

### Fragment Animation

Control whether the annotation appears with Reveal.js fragment animations.

**Parameter:**
- `fragment`: Set to `"false"` to disable animation (default: `true`)

**Example:**
```markdown
{{< hovering-annotation 
  annotation="Appears immediately" 
  fragment="false" 
>}}
```

## Complete Example

```markdown
{{< hovering-annotation 
  annotation="This is a fully customized annotation with all features"
  box-x="65" 
  box-y="30" 
  head-x="50" 
  head-y="22"
  mark-x="50"
  mark-y="22"
  annotation-width="35%"
  color="2"
  mark-width="1.5em"
  mark-height="1.5em"
  mark-opacity="0.6"
  fragment="true"
>}}
```
