return {
  'nvim-java/nvim-java',
  -- require('java').setup()
  config = function()
    local njava = require('java')
    njava.setup()
  end
}
