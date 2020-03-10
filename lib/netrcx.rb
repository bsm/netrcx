require 'shellwords'
require 'ostruct'

class Netrcx
  class Entry < OpenStruct
    def default?
      default == true
    end
  end

  def self.default_path
    home = ENV['NETRC']
    home ||= Dir.home if Dir.respond_to?(:home)
    home ||= ENV['HOME']

    if /mswin|mingw/.match?(RbConfig::CONFIG['host_os'])
      home ||= File.join(ENV['HOMEDRIVE'], ENV['HOMEPATH']) if ENV['HOMEDRIVE'] && ENV['HOMEPATH']
      home ||= ENV['USERPROFILE']
      File.join home, '_netrc'
    else
      File.join home, '.netrc'
    end
  end

  # Read from a file path.
  def self.read(path = default_path)
    File.open(path) {|io| new(io) }
  end

  attr_reader :entries

  def initialize(raw)
    @entries = []
    current  = nil
    lastword = nil

    raw.each_line do |line|
      Shellwords.split(line).each do |word|
        break if word.start_with?('#')

        if word == 'default'
          @entries.push(current) if current
          current = Entry.new(default: true)
        elsif word == 'machine'
          @entries.push(current) if current
          current = Entry.new(default: false)
        elsif !current.nil?
          set_value(current, lastword, word)
        end

        lastword = word
      end
    end
    @entries.push(current) if current
  end

  # @return [Netrcx::Entry] default entry
  def default
    entries.detect(&:default)
  end

  # @return [Netrcx::Entry] entry for the host
  def [](host)
    host = host.strip
    entries.detect {|m| m.host == host }
  end

  private

  def set_value(current, lastword, word)
    case lastword
    when 'machine'
      current.host = word
    when 'login'
      current.login = word
    when 'password'
      current.password = word
    when 'account'
      current.account = word
    end
  end
end
