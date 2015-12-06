require 'aws/decider'
require './util'
require './decider'

my_workflow_client = AWS::Flow.workflow_client($SWF.client, $DOMAIN){{from_class: 'TestSwfWorkflow'}}
puts "Starting an execution..."
workflow_execution = my_workflow_client.start_execution('AWS Flow Framework for Ruby')
