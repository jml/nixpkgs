# TODO share code with thunderbird-bin/generate_sources.rb

require "open-uri"

version =
  if ARGV.empty?
    $stderr.puts("Usage: ruby generate_sources.rb <version> > sources.nix")
    exit(-1)
  else
    ARGV[0]
  end

base_path = "http://archive.mozilla.org/pub/firefox/releases"

Source = Struct.new(:hash, :arch, :locale, :filename)

sources = open("#{base_path}/#{version}/SHA512SUMS") do |input|
  input.readlines
end.select do |line|
  /\/firefox-.*\.tar\.bz2$/ === line && !(/source/ === line)
end.map do |line|
  hash, name = line.chomp.split(/ +/)
  Source.new(hash, *(name.split("/")))
end.sort_by do |source|
  [source.locale, source.arch]
end

arches = ["linux-i686", "linux-x86_64"]

puts(<<"EOH")
# This file is generated from generate_sources.rb. DO NOT EDIT.
# Execute the following command to update the file.
#
# ruby generate_sources.rb 46.0.1 > sources.nix

{
  version = "#{version}";
  sources = [
EOH

sources.each do |source|
  puts(%Q|    { locale = "#{source.locale}"; arch = "#{source.arch}"; sha512 = "#{source.hash}"; }|)
end

puts(<<'EOF')
  ];
}
EOF
