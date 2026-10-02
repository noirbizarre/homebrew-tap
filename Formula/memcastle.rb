# Homebrew formula template.
#
# `0.1.0` and the `@SHA256_*@` placeholders are substituted by
# .github/workflows/homebrew.yaml from the published release assets, and the
# result is pushed to noirbizarre/homebrew-tap as Formula/memcastle.rb.
class Memcastle < Formula
  desc "Local-first, always-on memory server for AI coding agents over MCP/HTTP"
  homepage "https://github.com/noirbizarre/memcastle"
  version "0.1.0"
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
      sha256 "302dace383ab0fd76e1ff25ab6b556d63f6ecf941e05097093f69eeb3e9c760a"
    end
    on_intel do
      url "https://github.com/noirbizarre/memcastle/releases/download/#{version}/memcastle_#{version}_darwin-amd64"
      sha256 "17a0428900bda1149e23d20245601ced865d7c8d18c68318e33d3a343233953a"
    end
  end

  def install
    # Exactly one file lands here, whichever `url` above matched — renamed on
    # the way in because the downloaded asset's name carries the platform
    # suffix, not the command users are meant to type.
    bin.install Dir["*"].first => "memcastle"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/memcastle --version")
  end
end
