require_relative "lib/swarmpod/core/version"

Gem::Specification.new do |spec|
  spec.name          = "swarmpod-core"
  spec.version       = Swarmpod::Core::VERSION
  spec.authors       = ["Eric Laquer"]
  spec.summary       = "Onboarding companion for SwarmPod"
  spec.description   = "Verify scripts and guided setup for new SwarmPod team members. " \
                        "Checks Anthropic, GitHub, Hostinger, and Z.AI service connections."
  spec.homepage      = "https://github.com/CbiPerson/swarmpod-core"
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 2.7"

  spec.files = Dir.chdir(__dir__) do
    Dir["{bin,lib,secrets_example}/**/*", "VERSION", "README.md", "LICENSE"]
  end

  spec.bindir        = "bin"
  spec.executables   = Dir["bin/*"].map { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
