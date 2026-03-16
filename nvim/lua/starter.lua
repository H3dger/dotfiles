local M = {}

local function map_item(label, action, section)
  return {
    action = action,
    name = label,
    section = section,
  }
end

local function notes_path()
  local candidates = {
    vim.fn.expand("~/notes"),
    vim.fn.expand("~/Documents/notes"),
    vim.fn.expand("~/Documents"),
  }

  for _, path in ipairs(candidates) do
    if vim.fn.isdirectory(path) == 1 then
      return path
    end
  end

  return vim.fn.expand("~")
end

local function projects_items()
  local candidates = {
    vim.fn.expand("~/projects"),
    vim.fn.expand("~/work"),
    vim.fn.expand("~/code"),
    vim.fn.expand("~/research"),
  }
  local items = {}

  for _, path in ipairs(candidates) do
    if vim.fn.isdirectory(path) == 1 then
      items[#items + 1] = map_item(vim.fn.fnamemodify(path, ":~"), "lua vim.cmd('cd " .. vim.fn.fnameescape(path) .. "')", "Projects")
    end
  end

  if vim.fn.getcwd() ~= vim.fn.expand("~") then
    items[#items + 1] = map_item(vim.fn.fnamemodify(vim.fn.getcwd(), ":~"), "lua vim.cmd('cd " .. vim.fn.fnameescape(vim.fn.getcwd()) .. "')", "Projects")
  end

  local result = {}
  for i = 1, math.min(#items, 3) do
    result[#result + 1] = items[i]
  end

  return result
end

local function open_path(path)
  return function()
    vim.cmd.edit(vim.fn.fnameescape(path))
  end
end

local function prompt_find_file()
  vim.ui.input({ prompt = "Open file: ", completion = "file" }, function(input)
    if not input or input == "" then
      return
    end
    vim.cmd.edit(vim.fn.fnameescape(vim.fn.expand(input)))
  end)
end

local function footer()
  local datetime = os.date("%Y-%m-%d  %H:%M")
  local version = vim.version()
  local nvim_version = string.format("NVIM %d.%d.%d", version.major, version.minor, version.patch)

  return string.format("%s   %s   catppuccin mocha", datetime, nvim_version)
end

function M.setup()
  local starter = require("mini.starter")

  starter.setup({
    autoopen = true,
    evaluate_single = true,
    header = table.concat({
      "",
      "",
      "",
      "",
      "shanhanjie.nvim",
      "",
      "research-ready editing",
      "",
    }, "\n"),
    footer = footer,
    items = {
      map_item("New file", "ene | startinsert", "Actions"),
      map_item("Find file", prompt_find_file, "Actions"),
      map_item("Config", open_path(vim.fn.stdpath("config") .. "/init.lua"), "Actions"),
      map_item("Notes", open_path(notes_path()), "Actions"),
      map_item("Quit", "qa", "Actions"),
      starter.sections.recent_files(5, true, false),
      projects_items(),
    },
    content_hooks = {
      starter.gen_hook.adding_bullet("  > "),
      starter.gen_hook.aligning("center", "center"),
      starter.gen_hook.indexing("all", { "e", "f", "r", "c", "n", "q" }),
      function(content)
        local palette = require("catppuccin.palettes").get_palette("mocha")
        vim.api.nvim_set_hl(0, "MiniStarterHeader", { fg = palette.sapphire, bold = true, italic = true })
        vim.api.nvim_set_hl(0, "MiniStarterSection", { fg = palette.overlay1, bold = true })
        vim.api.nvim_set_hl(0, "MiniStarterItem", { fg = palette.text })
        vim.api.nvim_set_hl(0, "MiniStarterItemPrefix", { fg = palette.blue, bold = true })
        vim.api.nvim_set_hl(0, "MiniStarterFooter", { fg = palette.surface2, italic = true })
        return content
      end,
    },
  })

  vim.api.nvim_create_autocmd("User", {
    pattern = "MiniStarterOpened",
    callback = function()
      vim.wo.cursorline = false
    end,
  })

  vim.api.nvim_create_autocmd("BufEnter", {
    callback = function(ev)
      if vim.bo[ev.buf].filetype ~= "ministarter" then
        vim.wo.cursorline = true
      end
    end,
  })
end

return M
