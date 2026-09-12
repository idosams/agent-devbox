#!/usr/bin/env ruby
# frozen_string_literal: true

root = File.expand_path("..", __dir__)
markdown_files = Dir.glob(File.join(root, "**", "*.md"), File::FNM_DOTMATCH)
missing = []

markdown_files.each do |source|
  text = File.read(source)
  text.scan(/\[[^\]]+\]\(([^)]+)\)/).flatten.each do |target|
    next if target.match?(%r{\A(?:https?://|mailto:|#)})

    path = target.split("#", 2).first
    next if path.empty?

    destination = File.expand_path(path, File.dirname(source))
    missing << "#{source.delete_prefix(root + "/")}: #{target}" unless File.exist?(destination)
  end
end

unless missing.empty?
  warn "Broken local Markdown links:\n  #{missing.join("\n  ")}"
  exit 1
end

puts "Local Markdown links passed."
