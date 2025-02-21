return {
  'danielyaba/terraform.nvim',
  config = function()
    -- Load the Terraform module
    local terraform = require("terraform")
  end,

  -- Key mappings
  keys = {
    { "<leader>tfp",  function() require("terraform").plan() end,               desc = "Terraform Plan" },
    { "<leader>tfi",  function() require("terraform").init() end,               desc = "Terraform Init" },
    { "<leader>tfa",  function() require("terraform").apply() end,              desc = "Terraform Apply" },
    { "<leader>tfaa", function() require("terraform").apply_auto_approve() end, desc = "Terraform Apply Auto-Approve" },
  }
}
