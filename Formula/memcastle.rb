# Homebrew formula template.
#
# `0.4.0` and the `@SHA256_*@` placeholders are substituted by
# .github/workflows/homebrew.yaml from the published release assets, and the
# result is pushed to noirbizarre/homebrew-tap as Formula/memcastle.rb.
class Memcastle < Formula
  desc "Local-first, always-on memory server for AI coding agents over MCP/HTTP"
  homepage "https://github.com/noirbizarre/memcastle"
  version "0.4.0"
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
      sha256 "e933dfb26afe50ee71ba6ddc3e235e1a398bf15bd4da530778745caacb598136"
    end
    on_intel do
      url "https://github.com/noirbizarre/memcastle/releases/download/#{version}/memcastle_#{version}_darwin-amd64"
      sha256 "95daffc3bb56648d954131597bf3ce2d0622db435fc663625724e0c63538f179"
    end
  end

  # The sources bundled with MemCastle (docs/adr/040): portable WebAssembly packages, unpacked one directory each, one
  # asset for every platform. Homebrew strips the archive's single top-level directory when it stages the resource.
  resource "sources" do
    url "https://github.com/noirbizarre/memcastle/releases/download/#{version}/memcastle_#{version}_sources.tar.gz"
    sha256 "b6781339a868c17279b9a04f15307426542ee6408f3f08afbab9138e4e04cd3f"
  end

  # The agent integrations and the shared skills they read (docs/adr/034): bundled JavaScript, one asset for every
  # platform, with `integrations/` and `skills/` under its single top-level directory.
  resource "integrations" do
    url "https://github.com/noirbizarre/memcastle/releases/download/#{version}/memcastle_#{version}_integrations.tar.gz"
    sha256 "95276b6e076bde9a7e0a7e3108b852ea70540a338ca2c0e6a7f5d434ac5240c0"
  end

  # The web UI (docs/adr/035): static files, one asset for every platform, with `web/` under its single top-level
  # directory.
  resource "web" do
    url "https://github.com/noirbizarre/memcastle/releases/download/#{version}/memcastle_#{version}_web.tar.gz"
    sha256 "9a4d993963991e65f4e48a779284e6181b8e10666244c25e1877afa07e7df092"
  end

  def install
    # Exactly one file lands here, whichever `url` above matched — renamed on
    # the way in because the downloaded asset's name carries the platform
    # suffix, not the command users are meant to type.
    bin.install Dir["*"].first => "memcastle"

    # Beside the binary's prefix, where the daemon looks for them (`share/memcastle/sources`), so
    # `memcastle source enable pi` is all they need: no registry and no network.
    resource("sources").stage { (pkgshare/"sources").install Dir["*"] }

    # Likewise `share/memcastle/{integrations,skills}`, where `memcastle integration install pi` looks.
    resource("integrations").stage do
      (pkgshare/"integrations").install Dir["integrations/*"]
      (pkgshare/"skills").install Dir["skills/*"]
    end

    # And `share/memcastle/web/dist`, which the daemon serves under `/ui` when `web.enable` is set.
    resource("web").stage { (pkgshare/"web").install Dir["web/*"] }

    # Generated from the installed binary, so the scripts always match its
    # commands and flags; `memcastle completions <shell>` needs no daemon.
    generate_completions_from_executable(bin/"memcastle", "completions", shells: [:bash, :zsh, :fish])
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/memcastle --version")
    assert_path_exists pkgshare/"sources/pi/source.wasm"
    assert_path_exists pkgshare/"integrations/pi/memcastle-integration.toml"
    assert_path_exists pkgshare/"skills/wake-up/SKILL.md"
    assert_path_exists pkgshare/"web/dist/index.html"

  end
end
