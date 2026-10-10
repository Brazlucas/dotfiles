# cyberpunk.nvim

Tema cyberpunk para Neovim: fundo **transparente** (combina com terminal em vidro/Acrylic),
acentos neon (rosa `#ff2a6d`, ciano `#05f2ff`, azul, menta, amarelo) e grupos do Snacks picker,
neo-tree e bufferline ajustados. Base: `wildcharm` (já vem com o Neovim ≥ 0.10).

## Instalar

**Direto do repo de dotfiles (lazy.nvim / LazyVim)**

```lua
{
  "Brazlucas/dotfiles",
  name = "cyberpunk.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    vim.opt.rtp:append(vim.fn.stdpath("data") .. "/lazy/cyberpunk.nvim/themes/cyberpunk.nvim")
    vim.cmd.colorscheme("cyberpunk")
  end,
}
```

**Manual (sem plugin manager)**

```sh
mkdir -p ~/.config/nvim/colors
cp colors/cyberpunk.lua ~/.config/nvim/colors/
```

e, no `init.lua`: `vim.cmd.colorscheme("cyberpunk")`.

## Paleta

| papel      | cor       |
|------------|-----------|
| texto      | `#d3dcea` |
| comentário | `#5c6b80` |
| rosa       | `#ff2a6d` |
| ciano      | `#05f2ff` |
| azul       | `#3d8bff` |
| violeta    | `#b45cff` |
| menta      | `#00ffa3` |
| amarelo    | `#fcee0a` |
| seleção    | `#12404a` |

Para fundo opaco, troque os `bg = "NONE"` do bloco "fundo transparente" por `#080b10`.
