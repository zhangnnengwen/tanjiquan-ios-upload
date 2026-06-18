require "yaml"

config = YAML.load_file("codemagic.yaml")
workflow = config.fetch("workflows").fetch("upload-ios-ipa")
triggering = workflow.fetch("triggering")

events = triggering.fetch("events")
raise "triggering.events must include push" unless events.include?("push")

branch_patterns = triggering.fetch("branch_patterns")
main_branch = branch_patterns.find { |pattern| pattern.fetch("pattern") == "main" }
raise "triggering.branch_patterns must include main" unless main_branch
raise "main branch trigger must be enabled" unless main_branch.fetch("include")

puts "codemagic trigger verification passed"
