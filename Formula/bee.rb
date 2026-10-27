# Homebrew formula template.
#
# `0.1.1` and the `@SHA256_*@` placeholders are substituted by
# .github/workflows/homebrew.yaml from the published release assets, and the
# result is pushed to noirbizarre/homebrew-tap as Formula/bee.rb.
class Bee < Formula
  desc "A minimal, headless Rust agent runtime implementing ACPv2."
  homepage "https://github.com/noirbizarre/bee"
  version "0.1.1"
  license "MIT"

  # The release asset is the raw executable itself, not an archive — this
  # project's publish workflow uploads one so it can become a `gh` extension
  # without renaming assets later, and Homebrew installs a bare download
  # exactly as well as an archived one.
  #
  # This project tags without a `v` prefix, so the tag is `#{version}` as-is.
  on_macos do
    on_arm do
      url "https://github.com/noirbizarre/bee/releases/download/#{version}/bee_#{version}_darwin-arm64"
      sha256 "1a08f7c15cfac052d9481143111691a5e408c3c428c2eb30fd0317d8d9adad89"
    end
    on_intel do
      url "https://github.com/noirbizarre/bee/releases/download/#{version}/bee_#{version}_darwin-amd64"
      sha256 "2bcdf9f2a0d9a64ca501be8f64119a8b1c2122f249b8af9761f9d7afe6a537a2"
    end
  end

  # musl rather than gnu: the binary is statically linked, so it runs on any
  # distribution Homebrew supports regardless of its glibc.
  on_linux do
    on_intel do
      url "https://github.com/noirbizarre/bee/releases/download/#{version}/bee_#{version}_linux-amd64-musl"
      sha256 "7eb17a6438a5d2d3f0fc65e9bc8aa7fb0168bff2f8ee19c81c056f3a92101aac"
    end
  end

  def install
    # Exactly one file lands here, whichever `url` above matched — renamed on
    # the way in because the downloaded asset's name carries the platform
    # suffix, not the command users are meant to type.
    bin.install Dir["*"].first => "bee"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/bee --version")
  end
end
