function annotate(args, kwargs, meta)
  -- Extract parameters with proper defaults
  local box_x = tonumber(pandoc.utils.stringify(kwargs["box-x"] or "50"))
  local box_y = tonumber(pandoc.utils.stringify(kwargs["box-y"] or "50"))
  local annotation = pandoc.utils.stringify(kwargs["annotation"] or "")
  local annotation_width = pandoc.utils.stringify(kwargs["annotation-width"] or "50%")
  local mark_width = pandoc.utils.stringify(kwargs["mark-width"] or "1.2em")
  local mark_height = pandoc.utils.stringify(kwargs["mark-height"] or "1.2em")
  local mark_opacity = pandoc.utils.stringify(kwargs["mark-opacity"] or "0.5")
  
  -- Allow color to be a variable name (1-5) or a hex color
  -- Convert numbers to brand SCSS variable references
  local color_input = pandoc.utils.stringify(kwargs["col"] or "1")
  local color = color_input:match("^[1-9]$") and ("var(--brand-annotation-color-" .. color_input .. ")") or color_input
  
  local use_fragment = kwargs["fragment"] == nil or pandoc.utils.stringify(kwargs["fragment"]) ~= "false"
  
  local has_mark = kwargs["mark-x"] and kwargs["mark-y"]
  local has_head = kwargs["head-x"] and kwargs["head-y"]
  
  local arrow = nil
  
  if has_head then
    local head_x = tonumber(pandoc.utils.stringify(kwargs["head-x"]))
    local head_y = tonumber(pandoc.utils.stringify(kwargs["head-y"]))

    -- Only create arrow if conversion to number succeeded
    if head_x and head_y then
      -- Calculate relative offsets in percentages
      local offset_x = head_x - box_x
      local offset_y = head_y - box_y

      -- Create arrow div (nested inside text)
      arrow = pandoc.Div(
        {},
        {
          class = "annotation-arrow",
          style = string.format("--bx:%s; --by:%s; --col:%s;", offset_x, offset_y, color)
        }
      )
    end
  end

  -- Create text div with annotation content and arrow
  local text_content = { pandoc.Plain(pandoc.Str(annotation)) }
  if arrow then
    table.insert(text_content, arrow)
  end
  
  local text = pandoc.Div(
    text_content,
    {
      class = "annotation-text",
      style = string.format("top:%s%%; left:%s%%; max-width:%s; --col:%s;", box_y, box_x, annotation_width, color)
    }
  )

  quarto.doc.add_html_dependency({
    name = 'hovering-annotation',
    stylesheets = { 'hovering-annotation.css' }
  })

  -- Create mark div if mark coordinates are provided
  local content = { text }
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

return {
  ["hovering-annotation"] = annotate
}
