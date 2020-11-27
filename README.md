A rough prototype of RuboCop custom cops to split the function of [RSpec/FilePath](https://docs.rubocop.org/rubocop-rspec/2.0/cops_rspec.html#rspecfilepath) into the one that checks the suffix of the spec file names (CustomCops/SpecSuffix) and another one that does almost the same thing as RSpec/FilePath but the `SpecSuffixOnly` option is omitted (CustomCops/ConsistentFilePath).

```
$ bundle
$ bundle exec rubocop
Inspecting 7 files
...C.C.

Offenses:

spec/models/invalid_rspec.rb:1:1: C: CustomCops/SpecSuffix: Use '_spec.rb' as a suffix.
class Invalid; end
^
spec/models/invalid_rspec.rb:3:1: C: CustomCops/ConsistentFilePath: Spec path should end with invalid*_spec.rb.
RSpec.describe Invalid do
^^^^^^^^^^^^^^^^^^^^^^
spec/requests/models_spec_test.rb:1:1: C: CustomCops/SpecSuffix: Use '_spec.rb' as a suffix.
RSpec.describe 'Models test' do
^

7 files inspected, 3 offenses detected
```
