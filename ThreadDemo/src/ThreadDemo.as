package
{
import core.display.DisplayObjectContainer;
import core.display.Stage;
import core.events.Event;

import flash.utils.ByteArray;

import potato.concurrent.FileReadCommand;

import potato.concurrent.ThreadManager;

public class ThreadDemo extends DisplayObjectContainer
{
	public function ThreadDemo(args:String = ''):void
	{
		ThreadManager.init();

		Stage.getStage().addEventListener(Event.ENTER_FRAME, onScheduleHandler);
	}

	private function onScheduleHandler(e:Event):void
	{
		ThreadManager.addCommand(new FileReadCommand('ThreadMain.swf'), onReadedCallback);
	}



	private function onReadedCallback(content:ByteArray):void
	{
		trace('[Main]', '文件读取结果：', content ? content.bytesAvailable : 'null');

		content.clear();
	}
}
}