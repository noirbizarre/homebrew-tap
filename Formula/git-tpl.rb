# Homebrew formula template.
#
# `0.4.0` and the `@SHA256_*@` placeholders are substituted by
# .github/workflows/homebrew.yaml from the published release assets, and the
# result is pushed to noirbizarre/homebrew-tap as Formula/git-tpl.rb.
#
# The formula is named after the binary (`git-tpl`), which is also the crate
# name, because that is what `brew install noirbizarre/tap/git-tpl` spells.
class GitTpl < Formula
  desc "Git-native project templates"
  homepage "https://noirbizarre.github.io/git-tpl/"
  version "0.4.0"
  license "MIT"

  # Prebuilt binaries from the GitHub release rather than a source build:
  # installing takes no Rust toolchain, and libgit2 is already vendored into
  # each binary so there is nothing to link against.
  #
  # This project tags without a `v` prefix, so the tag is `#{version}` as-is.
  on_macos do
    on_arm do
      url "https://github.com/noirbizarre/git-tpl/releases/download/#{version}/git-tpl_#{version}_darwin-arm64.tar.gz"
      sha256 "a71480c33d10d2d829fe788ef7b64e95a76567fd8bd52ca9ae328fe7819c6513"
    end
    on_intel do
      url "https://github.com/noirbizarre/git-tpl/releases/download/#{version}/git-tpl_#{version}_darwin-amd64.tar.gz"
      sha256 "5ddc7cfc23ae497555cf9c9896c53d85d37a5ac8d0b73418cdb7d3fd2bfcaf90"
    end
  end

  # musl rather than gnu: the binary is statically linked, so it runs on any
  # distribution Homebrew supports regardless of its glibc. There is no
  # aarch64-musl leg in the release matrix, so Linux arm64 is left unsupported
  # rather than served a glibc-pinned binary that would fail at load time.
  on_linux do
    on_intel do
      url "https://github.com/noirbizarre/git-tpl/releases/download/#{version}/git-tpl_#{version}_linux-amd64-musl.tar.gz"
      sha256 "8b07f49254f767401b6210a248ce00b1fb7f455d9d9df9e40d579c6fc5b02102"
    end
  end

  # Not a build dependency — a usage one. Git is what resolves `git tpl` to
  # this executable, and every workflow in the documentation is a `git` one.
  depends_on "git"

  def install
    # The archive holds a plain `git-tpl` at its root, so there is nothing to
    # rename: Git only resolves `git tpl` through an executable called exactly
    # `git-tpl`.
    bin.install "git-tpl"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/git-tpl --version")
    assert_match "template", shell_output("#{bin}/git-tpl --help")
  end
end
