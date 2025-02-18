return {
  "desdic/greyjoy.nvim",
  keys = {
    -- { "<Leader>gr", "<cmd>Greyjoy<CR>",          desc = "[G]reyjoy [r]un" },
    -- { "<Leader>gt", "<cmd>GreyjoyTelescope<CR>", desc = "[G]reyjoy [t]elescope" },
    -- { "<Leader>gg", "<cmd>Greyjoy fast<CR>",     desc = "[G]reyjoy fast [g]roup" },
    -- { "<Leader>ge", "<cmd>Greyedit<CR>",         desc = "[G]reyjoy [e]edit before run" },
    { "<Leader>gm", "<cmd>Greyjoy makefile<CR>", desc = "Greyjoy Makefile" }
  },
  dependencies = {
    { "akinsho/toggleterm.nvim" },       -- Optional
    { "nvim-lua/plenary.nvim" },         -- Optional
    { "nvim-telescope/telescope.nvim" }, -- Optional
  },
  cmd = { "Greyjoy", "Greyedit", "GreyjoyTelescope" },
  config = function()
    local greyjoy = require("greyjoy")
    local condition = require("greyjoy.conditions")
    greyjoy.setup({
      output_results = "toggleterm",
      last_first = true,
      extensions = {
        generic = {
          commands = {
            ["run {filename}"] = { command = { "python3", "{filename}" }, filetype = "python" },
            ["build main.go"] = {
              command = { "go", "build", "main.go" },
              filetype = "go",
              filename = "main.go",
            },
            ["zig build"] = {
              command = { "zig", "build" },
              filetype = "zig",
            },
            ["cmake -S . -B target"] = {
              command = { "cmake", "-S", ".", "-B", "target" },
              condition = function(n)
                return condition.file_exists("CMakeLists.txt", n)
                    and not condition.directory_exists("target", n)
              end,
            },
          },
        },
        kitchen = { group_id = 2, targets = { "converge", "verify", "destroy", "test" }, include_all = false },
        docker_compose = { group_id = 3 },
        cargo = { group_id = 4 },
      },
      run_groups = { fast = { "generic", "makefile", "cargo", "docker_compose" } },
    })

    greyjoy.load_extension("makefile") -- optional
  end,
}
