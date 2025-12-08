vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "jdtls" })

local opts = {
    cmd = {
        "jdtls",
        "--quiet",
        "-Dlog.level=OFF",
        "-Dlog.protocol=false",
    },
    settings = {
        java = {
            trace = { server = "off" },
            signatureHelp = { enabled = true },
            validation = {
                enabled = false,
            },
        }
    },
    handlers = {
        ['language/status'] = function(_, result) end,  -- Ignore status updates
        ['$/progress'] = function(_, result, ctx) end,  -- Ignore progress updates
        ["textDocument/publishDiagnostics"] = function(_, result, ctx, config) 
            -- Only forward non-validation diagnostics
            local diagnostics = result.diagnostics or {}
            local filtered = vim.tbl_filter(function(diagnostic)
                return not (diagnostic.message:match("Validate") or diagnostic.message:match("Publish"))
            end, diagnostics)
            result.diagnostics = filtered
            vim.lsp.handlers["textDocument/publishDiagnostics"](_, result, ctx, config)
        end,
    }
}

require("lvim.lsp.manager").setup("jdtls", opts)
