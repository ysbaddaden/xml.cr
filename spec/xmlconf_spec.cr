require "./spec_helper"
require "colorize"

describe "xmlconf" do
  it "xmltest/valid/sa" do
    Dir.glob("xmlconf/xmltest/valid/sa/*.xml").sort.each do |path|
      File.open(path) { |file| CRXML.parse_xml(file) }
    rescue ex
      print_parse_error(path, ex)
      raise ex
    end
  end

  it "sun/valid" do
    Dir.glob("xmlconf/sun/valid/*.xml").sort.each do |path|
      File.open(path) { |file| CRXML.parse_xml(file) }
    rescue ex
      print_parse_error(path, ex)
      raise ex
    end
  end

  it "ibm/valid" do
    Dir.glob("xmlconf/ibm/valid/P*/*.xml").sort.each do |path|
      File.open(path) { |file| CRXML.parse_xml(file) }
    rescue ex
      print_parse_error(path, ex)
      raise ex
    end
  end

  it "ibm/xml-1.1/valid" do
    Dir.glob("xmlconf/ibm/xml-1.1/valid/P*/*.xml").sort.each do |path|
      File.open(path) { |file| CRXML.parse_xml(file) }
    rescue ex
      print_parse_error(path, ex)
      raise ex
    end
  end

  private def print_parse_error(path, ex)
    puts "Failed to parse #{path}:"
    puts

    l = 1
    File.open(path) do |file|
      while line = file.gets(chomp: true)
        print ' ' if l < 100
        print ' ' if l < 10
        print l.to_s.colorize(:dark_gray)
        print ' '
        print "|".colorize(:dark_gray)
        print ' '
        puts line

        if ex.is_a?(CRXML::Error)
          if l == ex.location.line
            (4 + ex.location.column).times { print ' ' }
            puts "^".colorize(:red)
            (4 + ex.location.column).times { print ' ' }
            puts ex.@message.colorize(:red)
          end
        end

        l += 1
      end
    end
  end
end
