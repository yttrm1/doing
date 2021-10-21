# frozen_string_literal: true

module Doing
  ##
  ## @brief      This class describes a single WWID item
  ##
  class Item
    attr_accessor :date, :title, :section, :note

    def initialize(date, title, section, note = nil)
      @date = date
      @title = title
      @section = section
      @note = Note.new

      @note.append_string(note) if note
    end

    def interval
      @interval ||= calc_interval
    end

    def end_date
      @end_date ||= Time.parse(Regexp.last_match(1)) if @title =~ /@done\((\d{4}-\d\d-\d\d \d\d:\d\d.*?)\)/
    end

    def equal?(other)
      return false if @title.strip != other.title.strip

      return false if @date != other.date

      @note ||= Note.new
      other.note ||= Note.new
      return false if @note.strip_lines != other.note.strip_lines

      true
    end

    def tags?(tags, bool = :and)
      tags = split_tags(tags)
      bool = bool.normalize_bool

      case bool
      when :and
        all_tags?(tags)
      when :not
        no_tags?(tags)
      else
        any_tags?(tags)
      end
    end

    def search(search)
      text = @title + @note.join(' ')
      pattern = case search.strip
                when %r{^/.*?/$}
                  search.sub(%r{/(.*?)/}, '\1')
                when /^'/
                  search.sub(/^'(.*?)'?$/, '\1')
                else
                  search.split('').join('.{0,3}')
                end
      text =~ /#{pattern}/i
    end

    private

    def calc_interval
      done = end_date
      return nil if done.nil?

      start = @date

      (done - start).to_i
    end

    def all_tags?(tags)
      tags.each do |tag|
        return false unless @title =~ /@#{tag}/
      end
      true
    end

    def no_tags?(tags)
      tags.each do |tag|
        return false if @title =~ /@#{tag}/
      end
      true
    end

    def any_tags?(tags)
      tags.each do |tag|
        return true if @title =~ /@#{tag}/
      end
      false
    end

    def split_tags(tags)
      tags = tags.split(/ *, */) if tags.is_a? String
      tags.map { |t| t.strip.sub(/^@/, '') }
    end
  end
end