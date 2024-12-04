return {
  'nvim-java/nvim-java',
  -- require('java').setup()
  config = function()
    local njava = require('java')
    njava.setup({
      settings = {
        java = {
          configuration = {
            root_markers = {
              'settings.gradle',
              'settings.gradle.kts',
              'pom.xml',
              'build.gradle',
              'mvnw',
              'gradlew',
              'build.gradle',
              'build.gradle.kts',
            },
          }
        }
      }
    })
  end
}
