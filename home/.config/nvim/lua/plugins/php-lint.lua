-- phpcs (PSR12) conflicts with Pint's laravel preset (e.g. `'a'.$b`).
-- Skip phpcs in projects that use Pint, since Pint is their source of truth.
return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters = {
        phpcs = {
          condition = function(ctx)
            return vim.fs.find({ "pint.json" }, { path = ctx.filename, upward = true })[1] == nil
          end,
        },
      },
    },
  },
}
