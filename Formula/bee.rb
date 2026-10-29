# Homebrew formula template.
#
# `0.2.0` and the `@SHA256_*@` placeholders are substituted by
# .github/workflows/homebrew.yaml from the published release assets, and the
# result is pushed to noirbizarre/homebrew-tap as Formula/bee.rb.
class Bee < Formula
  desc "A minimal, headless Rust agent runtime implementing ACPv2."
  homepage "https://github.com/noirbizarre/bee"
  version "0.2.0"
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
      sha256 "1654d6eda53d1cb5b99dd8b9107aacf24e6c0b9b1a157b11c3cb6abb4580b722"
    end
    on_intel do
      url "https://github.com/noirbizarre/bee/releases/download/#{version}/bee_#{version}_darwin-amd64"
      sha256 "4702cfad26ab2becca252815aaf5841fe9b4c384b7e954e7153e6c4babbd33d6"
    end
  end

  # musl rather than gnu: the binary is statically linked, so it runs on any
  # distribution Homebrew supports regardless of its glibc.
  on_linux do
    on_intel do
      url "https://github.com/noirbizarre/bee/releases/download/#{version}/bee_#{version}_linux-amd64-musl"
      sha256 "94c7395eb5a0b6395b2bc8350a445067b2b95cd02e5849a5af4ddac2fcd5795c"
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
