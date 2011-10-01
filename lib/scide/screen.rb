DEFAULT_HARDSTATUS = '%{= kG}[ %{G}%H %{g}][%= %{=kw}%?%-Lw%?%{r}(%{W}%n*%f%t%?(%u)%?%{r})%{w}%?%+Lw%?%?%= %{g}][%{B}%Y-%m-%d %{W}%c %{g}]'

module Scide

  class Screen

    def initialize config, cli, project_key
      @config, @cli = config, cli

      unless @config.projects.key? project_key
        Scide.fail :unknown_project, "ERROR: there is no project '#{project_key}' in configuration #{@config.file}."
      end
      @project = config.projects[project_key]
    end

    def run
      file = Tempfile.new 'scide'
      save file
      system to_command(file.path)
      file.unlink
    end

    def to_command tmp_file = 'TEMPORARY_FILE'
      "cd #{@project.path} && #{binary} #{options} -c #{tmp_file}"
    end

    def validate
      Scide.fail :screen_not_found, "ERROR: #{binary} not found" unless system("which #{binary}", { [ :out, :err ] => :close })
    end

    def to_s
      String.new.tap do |s|
        s << "startup_message off\n"
        s << "hardstatus on\n"
        s << "hardstatus alwayslastline\n"
        s << "hardstatus string '#{DEFAULT_HARDSTATUS}'\n\n"
        s << @project.to_screen
      end
    end

    private

    def binary
      @config.screen.try(:[], :binary) || 'screen'
    end

    def options
      @config.screen.try(:[], :options)
    end

    def save file
      File.open(file.path, 'w'){ |f| f.write to_s }
    end
  end
end
