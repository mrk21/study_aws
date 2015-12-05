require '../util'
require 'aws/decider'

$DOMAIN = "TestSwfDomain"
$SWF = AWS::SimpleWorkflow.new

begin
  $DOMAIN = $SWF.domains.create($DOMAIN, "10")
rescue AWS::SimpleWorkflow::Errors::DomainAlreadyExistsFault => e
  $DOMAIN = $SWF.domains[$DOMAIN]
end

$TASK_LIST = 'test_swf_task_list'
