module Crystal
  module Config
    PATH    = {{ env("CRYSTAL_CONFIG_PATH") || "" }}
    VERSION = {{ env("CRYSTAL_CONFIG_VERSION") || `(git describe --tags --long 2>/dev/null)`.stringify.chomp }}

    def self.path
      PATH
    end

    def self.version
      VERSION
    end

    def self.description
      tag, sha = tag_and_sha
      if sha
        "Crystal #{tag} [#{sha}] (#{date})"
      else
        "Crystal #{tag} (#{date})"
      end
    end

    def self.tag_and_sha
      pieces = version.split("-")
      tag = pieces[0]? || "?"
      sha = pieces[2]?
      if sha
        sha = sha[1..-1] if sha.starts_with? 'g'
      end
      {tag, sha}
    end

    def self.full_date
      {{ `date -u`.stringify.chomp }}
    end

    def self.date
      string = full_date
      time = Time.parse(string, "%a %b %d %H:%M:%S UTC %Y")
      time.to_s("%Y-%m-%d")
    end
  end
end
