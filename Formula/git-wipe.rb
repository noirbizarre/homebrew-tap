# Homebrew formula template.
#
# `0.8.0` and the `@SHA256_*@` placeholders are substituted by
# .github/workflows/homebrew.yaml from the published release assets, and the
# result is pushed to noirbizarre/homebrew-tap as Formula/git-wipe.rb.
class GitWipe < Formula
  desc "Wipe out merged local branches and worktrees"
  homepage "https://github.com/noirbizarre/git-wipe"
  version "0.8.0"
  license "MIT"

  # The release archive, not the raw executable: it carries the man pages and
  # completions the bare binary cannot. Homebrew strips the archive's single
  # top-level directory, so the paths in `install` start at `bin/`.
  #
  # This project tags without a `v` prefix, so the tag is `#{version}` as-is.
  on_macos do
    on_arm do
      url "https://github.com/noirbizarre/git-wipe/releases/download/#{version}/git-wipe_#{version}_darwin-arm64.tar.gz"
      sha256 "95197d2e1106068edf59d14971d54dae9672c4307ffb47fb5ad727b21eeba719"
    end
    on_intel do
      url "https://github.com/noirbizarre/git-wipe/releases/download/#{version}/git-wipe_#{version}_darwin-amd64.tar.gz"
      sha256 "6b159d11dbc0c1f51ae37c4871d02bb7dcaeeb8c95a5a3cd47a1a52247cbcf80"
    end
  end

  # musl rather than gnu: the binary is statically linked, so it runs on any
  # distribution Homebrew supports regardless of its glibc.
  on_linux do
    on_intel do
      url "https://github.com/noirbizarre/git-wipe/releases/download/#{version}/git-wipe_#{version}_linux-amd64-musl.tar.gz"
      sha256 "38c29c762360945e0ab6dc842f8d5d32bef74f1690c1ca93e78a9ffe7a516e38"
    end
    on_arm do
      url "https://github.com/noirbizarre/git-wipe/releases/download/#{version}/git-wipe_#{version}_linux-arm64-musl.tar.gz"
      sha256 "1c2b039882295f7e3242d1d54701eef326478a2c4d095b04a01cd6593530119d"
    end
  end

  # Every operation shells out to git.
  depends_on "git"

  def install
    bin.install "bin/git-wipe"

    # Each is optional: the archive only carries what the project generates.
    man1.install Dir["share/man/man1/*.1"] unless Dir["share/man/man1/*.1"].empty?
    bash_completion.install "share/bash-completion/completions/git-wipe" if File.exist?("share/bash-completion/completions/git-wipe")
    zsh_completion.install "share/zsh/site-functions/_git-wipe" if File.exist?("share/zsh/site-functions/_git-wipe")
    fish_completion.install "share/fish/vendor_completions.d/git-wipe.fish" if File.exist?("share/fish/vendor_completions.d/git-wipe.fish")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/git-wipe --version")
    assert_match "worktree", shell_output("#{bin}/git-wipe --help")
  end
end
