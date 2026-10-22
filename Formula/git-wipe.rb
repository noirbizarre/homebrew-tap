# Homebrew formula template.
#
# `0.6.0` and the `@SHA256_*@` placeholders are substituted by
# .github/workflows/homebrew.yaml from the published release assets, and the
# result is pushed to noirbizarre/homebrew-tap as Formula/git-wipe.rb.
class GitWipe < Formula
  desc "Wipe out merged local branches and worktrees"
  homepage "https://github.com/noirbizarre/git-wipe"
  version "0.6.0"
  license "MIT"

  # The release archive, not the raw executable: it carries the man pages and
  # completions the bare binary cannot. Homebrew strips the archive's single
  # top-level directory, so the paths in `install` start at `bin/`.
  #
  # This project tags without a `v` prefix, so the tag is `#{version}` as-is.
  on_macos do
    on_arm do
      url "https://github.com/noirbizarre/git-wipe/releases/download/#{version}/git-wipe_#{version}_darwin-arm64.tar.gz"
      sha256 "fc4d0d2975aa21fe27f6e57f4f08333bed612679ed95456a6e4a37b8721d07a0"
    end
    on_intel do
      url "https://github.com/noirbizarre/git-wipe/releases/download/#{version}/git-wipe_#{version}_darwin-amd64.tar.gz"
      sha256 "8b47ea52601b72d29486fb0639e53a7a95c650f175e49b3e9bf2d0d382c71546"
    end
  end

  # musl rather than gnu: the binary is statically linked, so it runs on any
  # distribution Homebrew supports regardless of its glibc.
  on_linux do
    on_intel do
      url "https://github.com/noirbizarre/git-wipe/releases/download/#{version}/git-wipe_#{version}_linux-amd64-musl.tar.gz"
      sha256 "0af87e4c4f04078faa84d50e263fb838049e4abcd6ba01f1283fe2c68b247c3c"
    end
    on_arm do
      url "https://github.com/noirbizarre/git-wipe/releases/download/#{version}/git-wipe_#{version}_linux-arm64-musl.tar.gz"
      sha256 "ddbf70f647dbd00b7ad2002918104907cfa14ebb5165181d3862eaa75629bef2"
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
