# Homebrew formula template.
#
# `0.3.0` and the `@SHA256_*@` placeholders are substituted by
# .github/workflows/homebrew.yaml from the published release assets, and the
# result is pushed to noirbizarre/homebrew-tap as Formula/memcastle.rb.
class Memcastle < Formula
  desc "Local-first, always-on memory server for AI coding agents over MCP/HTTP"
  homepage "https://github.com/noirbizarre/memcastle"
  version "0.3.0"
  license "MIT"

  # The release asset is the raw executable itself, not an archive — this
  # project's publish workflow uploads one so it can become a `gh` extension
  # without renaming assets later, and Homebrew installs a bare download
  # exactly as well as an archived one.
  #
  # This project tags without a `v` prefix, so the tag is `#{version}` as-is.
  on_macos do
    on_arm do
      url "https://github.com/noirbizarre/memcastle/releases/download/#{version}/memcastle_#{version}_darwin-arm64"
      sha256 "11e669904943524977c74ccca3b48a111eadc37b508174eb52bffc345c094f03"
    end
    on_intel do
      url "https://github.com/noirbizarre/memcastle/releases/download/#{version}/memcastle_#{version}_darwin-amd64"
      sha256 "e1c6b560ae152405250cb9f5b582f6c77d1fad564abc8fcd9584d49f1fb3c959"
    end
  end

  # The sources bundled with MemCastle (docs/adr/033): portable WebAssembly packages with their index, one asset for every
  # platform. Homebrew strips the archive's single top-level directory when it stages the resource.
  resource "sources" do
    url "https://github.com/noirbizarre/memcastle/releases/download/#{version}/memcastle_#{version}_sources.tar.gz"
    sha256 "fda0ce4821d58534c1ed836498d931d47921693004418fb11dd4fbf19014b4ed"
  end

  # The agent integrations and the shared skills they read (docs/adr/034): bundled JavaScript, one asset for every
  # platform, with `integrations/` and `skills/` under its single top-level directory.
  resource "integrations" do
    url "https://github.com/noirbizarre/memcastle/releases/download/#{version}/memcastle_#{version}_integrations.tar.gz"
    sha256 "b1e0fc3a978b8307de5b046efd921d934eefec98e524d024f8dd3cfeafc2185a"
  end

  def install
    # Exactly one file lands here, whichever `url` above matched — renamed on
    # the way in because the downloaded asset's name carries the platform
    # suffix, not the command users are meant to type.
    bin.install Dir["*"].first => "memcastle"

    # Beside the binary's prefix, where the daemon looks for them (`share/memcastle/sources`), so
    # `memcastle source install pi` needs no registry and no network.
    resource("sources").stage { (pkgshare/"sources").install Dir["*"] }

    # Likewise `share/memcastle/{integrations,skills}`, where `memcastle integration install pi` looks.
    resource("integrations").stage do
      (pkgshare/"integrations").install Dir["integrations/*"]
      (pkgshare/"skills").install Dir["skills/*"]
    end

    # Generated from the installed binary, so the scripts always match its
    # commands and flags; `memcastle completions <shell>` needs no daemon.
    generate_completions_from_executable(bin/"memcastle", "completions", shells: [:bash, :zsh, :fish])
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/memcastle --version")
    assert_path_exists pkgshare/"sources/memcastle-index.json"
    assert_path_exists pkgshare/"integrations/pi/memcastle-integration.toml"
    assert_path_exists pkgshare/"skills/wake-up/SKILL.md"

  end
end
