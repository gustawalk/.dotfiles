return {
  'akinsho/toggleterm.nvim',
  config = function()
    -- Configuração do ToggleTerm
    require('toggleterm').setup {
      size = 20, -- Tamanho do terminal
      open_mapping = [[<c-l>]], -- Tecla para abrir o terminal
      hide_numbers = true, -- Esconde os números
      shade_terminals = true, -- Sombras nos terminais
      direction = 'horizontal', -- Pode ser 'horizontal', 'vertical' ou 'float'
      start_in_insert = true, -- Começar no modo de inserção
      close_on_exit = true, -- Fechar o terminal ao sair
      shell = vim.o.shell, -- Usar o shell padrão do sistema
    }
  end,
}
