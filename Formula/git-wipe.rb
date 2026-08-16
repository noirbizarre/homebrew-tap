# Homebrew formula template.
#
# `0.4.0` and the `@SHA256_*@` placeholders are substituted by
# .github/workflows/homebrew.yml from the published release assets, and the
# result is pushed to noirbizarre/homebrew-tap as Formula/git-wipe.rb.
#
# The formula is named after the binary (`git-wipe`), not the crate, because
# that is what `brew install noirbizarre/tap/git-wipe` has to spell.
class GitWipe < Formula
  desc "Wipe out merged local branches and worktrees"
  homepage "https://github.com/noirbizarre/git-wipe"
  version "0.4.0"
  license "MIT"

  # Prebuilt binaries from the GitHub release rather than a source build: the
  # archives already carry the man pages and completions, and installing takes
  # no Rust toolchain.
  on_macos do
    on_arm do
      url "https://github.com/noirbizarre/git-wipe/releases/download/v#{version}/git-wipe-aarch64-apple-darwin.tar.gz"
      sha256 "c1d5352a7ef44bfc0970e39530053983d7cfa190910b07ae4243a317ebf2c704"
    end
    on_intel do
      url "https://github.com/noirbizarre/git-wipe/releases/download/v#{version}/git-wipe-x86_64-apple-darwin.tar.gz"
      sha256 "7f71dfbe64ff314377277954c516026250ac5c89b5ce629d7e8dc4157232cbb1"
    end
  end

  # musl rather than gnu: the binaries are statically linked, so they run on
  # any distribution Homebrew supports regardless of its glibc.
  on_linux do
    on_arm do
      url "https://github.com/noirbizarre/git-wipe/releases/download/v#{version}/git-wipe-aarch64-unknown-linux-musl.tar.gz"
      sha256 "cc3eeff89fe7deb78f57bb29bda9ad6acba5b8f91327bc3d8812c9999a78f346"
    end
    on_intel do
      url "https://github.com/noirbizarre/git-wipe/releases/download/v#{version}/git-wipe-x86_64-unknown-linux-musl.tar.gz"
      sha256 "5e8c266e1c48863ec720b0f9c82456351c0d5091103fd657bc719d2bfee1db26"
    end
  end

  depends_on "git"

  def install
    bin.install "git-wipe"
    # Git rewrites `git wipe --help` into `git help wipe`, which runs
    # `man git-wipe`: the pages are what makes that work.
    man1.install Dir["man/*.1"]
    bash_completion.install "completions/git-wipe.bash" => "git-wipe"
    zsh_completion.install "completions/_git-wipe"
    fish_completion.install "completions/git-wipe.fish"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/git-wipe --version")
    assert_match "worktree", shell_output("#{bin}/git-wipe --help")
  end
end
