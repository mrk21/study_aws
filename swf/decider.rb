require './util'
require './worker'

class TestSwfWorkflow
  extend AWS::Flow::Workflows
  
  workflow :test_swf_workflow do
    {
      version: '1',
      execution_start_to_close_timeout: 3600,
      task_list: $TASK_LIST
    }
  end
  
  activity_client(:activity) {{from_class: 'TestSwfActivity'}}
  
  def test_swf_workflow(name)
    activity.test_swf_activity(name)
  end
end

worker = AWS::Flow::WorkflowWorker.new($SWF.client, $DOMAIN, $TASK_LIST, TestSwfWorkflow)
worker.start if __FILE__ == $0
