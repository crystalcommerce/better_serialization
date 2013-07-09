# A sample Guardfile
# More info at https://github.com/guard/guard#readme

rspec_options = {
  :all_after_pass => false,
  :all_after_start => false,
  :cli => '--drb --profile --color'
}

guard :rspec, rspec_options do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end
