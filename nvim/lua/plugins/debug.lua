return {
  'mfussenegger/nvim-dap',
  dependencies = { 'rcarriga/nvim-dap-ui', 'nvim-neotest/nvim-nio' },
  keys = {
    {
      '<F5>',
      function()
        require('dap').continue()
      end,
      desc = 'Debug: start / continue',
    },
    {
      '<F6>',
      function()
        require('dap').terminate()
      end,
      desc = 'Debug: stop',
    },
    {
      '<F7>',
      function()
        require('dapui').toggle()
      end,
      desc = 'Debug: toggle UI',
    },
    {
      '<F10>',
      function()
        require('dap').step_over()
      end,
      desc = 'Debug: step over',
    },
    {
      '<F11>',
      function()
        require('dap').step_into()
      end,
      desc = 'Debug: step into',
    },
    {
      '<F12>',
      function()
        require('dap').step_out()
      end,
      desc = 'Debug: step out',
    },
    {
      '<leader>db',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'Debug: toggle breakpoint',
    },
    {
      '<leader>dB',
      function()
        require('dap').set_breakpoint(vim.fn.input('Condition: '))
      end,
      desc = 'Debug: conditional breakpoint',
    },
  },
  config = function()
    local dap = require('dap')
    local dapui = require('dapui')
    dapui.setup()
    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- GDB 14+ has a built-in DAP server; this machine has GDB 17.
    dap.adapters.gdb = { type = 'executable', command = 'gdb', args = { '-i', 'dap' } }
    local launch = {
      name = 'Launch executable',
      type = 'gdb',
      request = 'launch',
      program = function()
        return vim.fn.input('Executable: ', vim.fn.getcwd() .. '/', 'file')
      end,
      cwd = '${workspaceFolder}',
      stopAtBeginningOfMainSubprogram = false,
    }
    dap.configurations.c = { launch }
    dap.configurations.cpp = dap.configurations.c
    dap.configurations.rust = dap.configurations.c
  end,
}
