# Homebrew formula template.
#
# `0.5.2` and the `@SHA256_*@` placeholders are substituted by
# .github/workflows/homebrew.yaml from the published release assets, and the
# result is pushed to noirbizarre/homebrew-tap as Formula/memcastle.rb.
class Memcastle < Formula
  desc "Local-first, always-on memory server for AI coding agents over MCP/HTTP"
  homepage "https://github.com/memcastle/memcastle"
  version "0.5.2"
  license "MIT"

  # The release asset is the raw executable itself, not an archive — this
  # project's publish workflow uploads one so it can become a `gh` extension
  # without renaming assets later, and Homebrew installs a bare download
  # exactly as well as an archived one.
  #
  # This project tags without a `v` prefix, so the tag is `#{version}` as-is.
  on_macos do
    on_arm do
      url "https://github.com/memcastle/memcastle/releases/download/#{version}/memcastle_#{version}_darwin-arm64"
      sha256 "c99c985165b935f78aff9210ace107ea202eaf1f7a5d9df604395a56656811ed"
    end
    on_intel do
      url "https://github.com/memcastle/memcastle/releases/download/#{version}/memcastle_#{version}_darwin-amd64"
      sha256 "1f2f5222200b96d8f396f6a8f1dc65c1bbed476d30a48c098304da1c873f5035"
    end
  end

  # Core's shared skills (docs/adr/020): Homebrew strips the archive's top-level directory when staging the resource.
  # Provider plugins carry their own sources and agent integrations.
  resource "skills" do
    url "https://github.com/memcastle/memcastle/releases/download/#{version}/memcastle_#{version}_skills.tar.gz"
    sha256 "64dd20d9530e04166768317f9f24c1752d6c0f6714bda73bb7f891e917b880bc"
  end

  # The web UI (docs/adr/035): static files, one asset for every platform, with `web/` under its single top-level
  # directory.
  resource "web" do
    url "https://github.com/memcastle/memcastle/releases/download/#{version}/memcastle_#{version}_web.tar.gz"
    sha256 "82d13599193ed2d1a404f1ac946d5d09c9956965e1c39d8c4206f820ca66af64"
  end

  def install
    # Exactly one file lands here, whichever `url` above matched — renamed on
    # the way in because the downloaded asset's name carries the platform
    # suffix, not the command users are meant to type.
    bin.install Dir["*"].first => "memcastle"

    # Keep empty compatibility roots beside the binary; install only the shared skills from Core.
    (pkgshare/"sources").mkpath
    (pkgshare/"integrations").mkpath
    resource("skills").stage { (pkgshare/"skills").install Dir["skills/*"] }

    # And `share/memcastle/web/dist`, which the daemon serves under `/ui` when `web.enable` is set.
    resource("web").stage { (pkgshare/"web").install Dir["web/*"] }

    # Generated from the installed binary, so the scripts always match its
    # commands and flags; `memcastle completions <shell>` needs no daemon.
    generate_completions_from_executable(bin/"memcastle", "completions", shells: [:bash, :zsh, :fish])
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/memcastle --version")
    assert_path_exists pkgshare/"sources"
    assert_path_exists pkgshare/"integrations"
    assert_path_exists pkgshare/"skills/wake-up/SKILL.md"
    assert_path_exists pkgshare/"web/dist/index.html"

  end
end
