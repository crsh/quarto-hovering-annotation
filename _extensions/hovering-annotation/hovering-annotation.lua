-- Helper function to parse color input
-- Converts color numbers (1-9) to CSS brand color variables
-- or returns the color string directly
function parse_color(color_input)
  local color_str = pandoc.utils.stringify(color_input or "1")
  return color_str:match("^[1-9]$") and ("var(--brand-annotation-color-" .. color_str .. ")") or color_str
end

-- Helper function to parse markdown text into inlines
-- Takes a string and returns a list of pandoc inline elements
function parse_markdown_to_inlines(text)
  local doc = pandoc.read(text, "markdown")
  local inlines = {}
  for _, block in ipairs(doc.blocks) do
    if block.t == "Para" or block.t == "Plain" then
      for _, inline in ipairs(block.content) do
        table.insert(inlines, inline)
      end
      -- Add space between paragraphs
      if #doc.blocks > 1 then
        table.insert(inlines, pandoc.Space())
      end
    end
  end
  return inlines
end

function annotate(args, kwargs, meta)
  -- Extract parameters with proper defaults
  local box_x = tonumber(pandoc.utils.stringify(kwargs["box-x"] or "50"))
  local box_y = tonumber(pandoc.utils.stringify(kwargs["box-y"] or "50"))
  local annotation_text = pandoc.utils.stringify(kwargs["annotation"] or "")
  local annotation_width = pandoc.utils.stringify(kwargs["annotation-width"] or "50%")
  local mark_width = pandoc.utils.stringify(kwargs["mark-width"] or "1.2em")
  local mark_height = pandoc.utils.stringify(kwargs["mark-height"] or "1.2em")
  local mark_opacity = pandoc.utils.stringify(kwargs["mark-opacity"] or "0.5")
  
  -- Parse annotation text as markdown to support formatting
  local annotation_inlines = parse_markdown_to_inlines(annotation_text)
  
  -- Parse color using helper function
  local color = parse_color(kwargs["color"])
  
  local use_fragment = kwargs["fragment"] == nil or pandoc.utils.stringify(kwargs["fragment"]) ~= "false"
  
  local has_mark = kwargs["mark-x"] and kwargs["mark-y"]
  local has_head = kwargs["head-x"] and kwargs["head-y"]
  
  local arrow = nil
  
  if has_head then
    local head_x = tonumber(pandoc.utils.stringify(kwargs["head-x"]))
    local head_y = tonumber(pandoc.utils.stringify(kwargs["head-y"]))

    -- Only create arrow if conversion to number succeeded
    if head_x and head_y then
      -- Create arrow div as sibling to text, positioned absolutely
      arrow = pandoc.Div(
        {},
        {
          class = "annotation-arrow",
          style = string.format("--ax:%s; --ay:%s; --bx:%s; --by:%s; --col:%s;", box_x, box_y, head_x, head_y, color)
        }
      )
    end
  end

  -- Create text div with annotation content (without arrow)
  local text = pandoc.Div(
    { pandoc.Plain(annotation_inlines) },
    {
      class = "annotation-text",
      style = string.format("top:%s%%; left:%s%%; max-width:%s; --col:%s;", box_y, box_x, annotation_width, color)
    }
  )

  quarto.doc.add_html_dependency({
    name = 'hovering-annotation',
    stylesheets = { 'hovering-annotation.css' }
  })

  -- Create content with text and optionally arrow as siblings
  local content = { text }
  if arrow then
    table.insert(content, arrow)
  end
  if has_mark then
    local mark_x = tonumber(pandoc.utils.stringify(kwargs["mark-x"]))
    local mark_y = tonumber(pandoc.utils.stringify(kwargs["mark-y"]))
    
    if mark_x and mark_y then
      local mark = pandoc.Div(
        {},
        {
          class = "annotation-mark",
          style = string.format("top:%s%%; left:%s%%; background-color:%s; width:%s; height:%s; opacity:%s;", mark_y, mark_x, color, mark_width, mark_height, mark_opacity)
        }
      )
      table.insert(content, mark)
    end
  end

  -- Build class string based on fragment option
  local outer_class = use_fragment and "annotation fragment" or "annotation"
  
  -- Return the complete annotation div
  return pandoc.Div(
    content,
    { class = outer_class }
  )
end

function mark(args, kwargs, meta)
  -- Extract parameters with defaults
  local color = parse_color(kwargs["color"])
  local opacity = tonumber(pandoc.utils.stringify(kwargs["opacity"] or "50")) or 50
  
  -- Get the text content (first positional argument)
  -- If it's a string, parse it as markdown
  local text_input = args[1]
  local text_inlines
  
  if type(text_input) == "string" then
    text_inlines = parse_markdown_to_inlines(text_input)
  else
    text_inlines = text_input or {}
  end
  
  -- Create span with mark class and inline style
  return pandoc.Span(
    text_inlines,
    pandoc.Attr(
      "",
      {"mark"},
      {
        style = string.format("background-color:color-mix(in srgb, %s %s%%, transparent %s%%); padding: 0.1em 0.4em; border-radius: 0.2em;", 
          color, opacity, 100 - opacity)
      }
    )
  )
end

return {
  ["hovering-annotation"] = annotate,
  ["mark"] = mark
}
