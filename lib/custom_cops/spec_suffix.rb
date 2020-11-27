# frozen_string_literal: true

module CustomCops
  # @example
  #   # bad
  #   my_class_rspec.rb
  #
  #   # good
  #   my_class_spec.rb
  class SpecSuffix < ::RuboCop::Cop::RSpec::Base
    include ::RuboCop::Cop::RangeHelp
    include ::RuboCop::Cop::RSpec::TopLevelGroup

    MSG = "Use '_spec.rb' as a suffix."

    def on_top_level_group(_node)
      return if filename_ends_with_spec_suffix?

      add_offense(range, message: format(MSG))
    end

    private

    def filename_ends_with_spec_suffix?
      File.fnmatch?(glob_for_spec_suffix, filename)
    end

    def glob_for_spec_suffix
      '*_spec.rb'
    end

    def filename
      RuboCop::PathUtil.relative_path(processed_source.buffer.name).gsub('../', '')
    end

    def range
      source_range(processed_source.buffer, 1, 0)
    end
  end
end
