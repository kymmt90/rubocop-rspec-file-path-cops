# frozen_string_literal: true

module CustomCops
  # @example
  #   # bad
  #   whatever_spec.rb         # describe MyClass
  #
  #   # bad
  #   my_class_spec.rb         # describe MyClass, '#method'
  #
  #   # good
  #   my_class_spec.rb         # describe MyClass
  #
  #   # good
  #   my_class_method_spec.rb  # describe MyClass, '#method'
  #
  #   # good
  #   my_class/method_spec.rb  # describe MyClass, '#method'
  #
  # @example when configuration is `IgnoreMethods: true`
  #   # bad
  #   whatever_spec.rb         # describe MyClass
  #
  #   # good
  #   my_class_spec.rb         # describe MyClass
  #
  #   # good
  #   my_class_spec.rb         # describe MyClass, '#method'
  #
  class ConsistentFilePath < ::RuboCop::Cop::RSpec::Base
    include ::RuboCop::Cop::RSpec::TopLevelGroup

    MSG = 'Spec path should end with `%<suffix>s`.'

    def_node_matcher :const_described, <<~PATTERN
      (block
        $(send #rspec? _example_group $(const ...) $...) ...
      )
    PATTERN

    def_node_search :routing_metadata?, '(pair (sym :type) (sym :routing))'

    def on_top_level_example_group(node)
      return unless top_level_groups.one?

      const_described(node) do |send_node, described_class, arguments|
        next if routing_spec?(arguments)

        ensure_correct_file_path(send_node, described_class, arguments)
      end
    end

    private

    def ensure_correct_file_path(send_node, described_class, arguments)
      glob = glob_for(described_class, arguments.first)

      return if filename_ends_with?(glob)

      add_offense(send_node, message: format(MSG, suffix: glob))
    end

    def routing_spec?(args)
      args.any?(&method(:routing_metadata?))
    end

    def glob_for(described_class, method_name)
      "#{expected_path(described_class)}#{name_glob(method_name)}*_spec.rb"
    end

    def name_glob(method_name)
      return unless method_name&.str_type?
      "*#{method_name.str_content.gsub(/\W/, '')}" unless ignore_methods?
    end

    def expected_path(constant)
      File.join(
        constant.const_name.split('::').map do |name|
          custom_transform.fetch(name) { camel_to_snake_case(name) }
        end
      )
    end

    def camel_to_snake_case(string)
      string
        .gsub(/([^A-Z])([A-Z]+)/, '\1_\2')
        .gsub(/([A-Z])([A-Z][^A-Z\d]+)/, '\1_\2')
        .downcase
    end

    def custom_transform
      cop_config.fetch('CustomTransform', {})
    end

    def ignore_methods?
      cop_config['IgnoreMethods']
    end

    def filename_ends_with?(glob)
      filename =
        RuboCop::PathUtil.relative_path(processed_source.buffer.name)
          .gsub('../', '')
      File.fnmatch?("*#{glob}", filename)
    end

    def relevant_rubocop_rspec_file?(_file)
      true
    end
  end
end
