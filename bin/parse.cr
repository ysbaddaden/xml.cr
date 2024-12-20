#! /usr/bin/env -S crystal i --
require "../src/crxml"
require "colorize"

def print_parse_error(path, ex)
  puts "Failed to parse #{path}:"
  puts

  line_number = 1
  File.open(path) do |file|
    # TODO: only print a few lines before and after, not the whole file
    while line = file.gets(chomp: true)
      print ' ' if line_number < 100
      print ' ' if line_number < 10
      print line_number.to_s.colorize(:dark_gray)
      print ' '
      print "|".colorize(:dark_gray)
      print ' '
      puts line

      if ex.is_a?(CRXML::Error)
        if line_number == ex.location.line
          (4 + ex.location.column).times { print ' ' }
          puts "^".colorize(:red)
          (4 + ex.location.column).times { print ' ' }
          puts ex.@message.colorize(:red)
        end
      end

      line_number += 1
    end

    if ex.is_a?(CRXML::Error) && line_number == ex.location.line
      print ' ' if line_number < 100
      print ' ' if line_number < 10
      print line_number.to_s.colorize(:dark_gray)
      print ' '
      print "|".colorize(:dark_gray)
      print ' '
      puts

      if ex.is_a?(CRXML::Error)
        if line_number == ex.location.line
          (4 + ex.location.column).times { print ' ' }
          puts "^".colorize(:red)
          (4 + ex.location.column).times { print ' ' }
          puts ex.@message.colorize(:red)
        end
      end
    end
  end
end

abort "fatal: missing argument" if ARGV.empty?

options = CRXML::Options::WellFormed
external = true
normalize = false
canonicalize = false

if ARGV.includes?("--wf=no")
  ARGV.delete("--wf=no")
  options ^= CRXML::Options::WellFormed
end

if ARGV.includes?("--external=no")
  ARGV.delete("--external=no")
  external = false
end

if ARGV.includes?("--normalize")
  ARGV.delete("--normalize")
  normalize = true
end

if ARGV.includes?("--canonicalize")
  ARGV.delete("--canonicalize")
  canonicalize = true
end

ARGV.sort.each do |path|
  puts
  puts "Parsing #{path} ..."
  puts
  File.open(path) do |file|
    document = CRXML.parse_xml(file, external: external, options: options)
    if normalize
      document.normalize
    elsif canonicalize
      document.canonicalize
    end
  rescue ex
    print_parse_error(path, ex)
    puts
    puts "#{ex.class.name}: #{ex.message}\n#{ex.backtrace.join('\n')}"
    # raise ex
  else
    document.inspect(STDOUT, indent: 0)
  end
end
