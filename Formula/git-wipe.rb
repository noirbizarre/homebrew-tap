# Homebrew formula template.
#
# `0.7.0` and the `@SHA256_*@` placeholders are substituted by
# .github/workflows/homebrew.yaml from the published release assets, and the
# result is pushed to noirbizarre/homebrew-tap as Formula/git-wipe.rb.
class GitWipe < Formula
  desc "Wipe out merged local branches and worktrees"
  homepage "https://github.com/noirbizarre/git-wipe"
  version "0.7.0"
  license "MIT"

  # The release archive, not the raw executable: it carries the man pages and
  # completions the bare binary cannot. Homebrew strips the archive's single
  # top-level directory, so the paths in `install` start at `bin/`.
  #
  # This project tags without a `v` prefix, so the tag is `#{version}` as-is.
  on_macos do
    on_arm do
      url "https://github.com/noirbizarre/git-wipe/releases/download/#{version}/git-wipe_#{version}_darwin-arm64.tar.gz"
      sha256 "778efff6556489ce1ebddf73a3ef253caf8638b5a1e341dde3c2c5a37a63f4b3"
    end
    on_intel do
      url "https://github.com/noirbizarre/git-wipe/releases/download/#{version}/git-wipe_#{version}_darwin-amd64.tar.gz"
      sha256 "d360eca70f516983ba46e0048f76d29476b1e5ca28a292f15e68bbc4beceafbe"
    end
  end

  # musl rather than gnu: the binary is statically linked, so it runs on any
  # distribution Homebrew supports regardless of its glibc.
  on_linux do
    on_intel do
      url "https://github.com/noirbizarre/git-wipe/releases/download/#{version}/git-wipe_#{version}_linux-amd64-musl.tar.gz"
      sha256 "32bb14c718d45937b3513fa72ec221ee105ee1c1e82b4f2e66bcaf0be6b50114"
    end
    on_arm do
      url "https://github.com/noirbizarre/git-wipe/releases/download/#{version}/git-wipe_#{version}_linux-arm64-musl.tar.gz"
      sha256 "44cb411b4dd78226a3180bdf787bd397b03fff8cc67a98c841cb3db18278606f"
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
