require "./rewriter"

class Ameba::Source
  class Corrector
    def self.correct(source : Source)
      code = source.code
      corrector = new(code)
      source.issues.each(&.correct(corrector))
      corrected_code = corrector.process
      return if code == corrected_code

      corrected_code
    end

    @line_sizes : Array(Int32)

    def initialize(code : String)
      @rewriter = Rewriter.new(code)
      @line_sizes = code.lines(chomp: false).map(&.size)
    end

    alias SourceLocation = Crystal::Location | {Int32, Int32}

    def replace(location : SourceLocation, end_location : SourceLocation, content)
      @rewriter.replace(loc_to_pos(location), loc_to_pos(end_location) + 1, content)
    end

    def wrap(location : SourceLocation, end_location : SourceLocation, insert_before, insert_after)
      @rewriter.wrap(loc_to_pos(location), loc_to_pos(end_location) + 1, insert_before, insert_after)
    end

    def remove(location : SourceLocation, end_location : SourceLocation)
      @rewriter.remove(loc_to_pos(location), loc_to_pos(end_location) + 1)
    end

    def insert_before(location : SourceLocation, content)
      @rewriter.insert_before(loc_to_pos(location), content)
    end

    def insert_after(location : SourceLocation, content)
      @rewriter.insert_after(loc_to_pos(location) + 1, content)
    end

    private def loc_to_pos(location : SourceLocation)
      if location.is_a?(Crystal::Location)
        line, column = location.line_number, location.column_number
      else
        line, column = location
      end
      @line_sizes[0...line - 1].sum + (column - 1)
    end

    def process
      @rewriter.process
    end
  end
end
