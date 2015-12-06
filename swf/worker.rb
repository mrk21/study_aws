require './util'

class TestSwfActivity
  extend AWS::Flow::Activities
  
  activity :test_swf_activity do
    {
      default_task_list: $TASK_LIST,
      version: 'my_first_activity',
      default_task_schedule_to_start_timeout: 30,
      default_task_start_to_close_timeout: 30,
    }
  end
  
  def test_swf_activity(name)
    puts "Hello, #{name}!"
  end
end

activity_worker = AWS::Flow::ActivityWorker.new($SWF.client, $DOMAIN, $TASK_LIST, TestSwfActivity){{use_forking: false}}
activity_worker.start if __FILE__ == $0
