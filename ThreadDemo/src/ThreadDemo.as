package
{
import core.display.DisplayObjectContainer;
import core.display.Stage;
import core.events.Event;

import flash.utils.ByteArray;

import potato.concurrent.FileReadCommand;
import potato.concurrent.FileWriteCommand;

import potato.concurrent.ThreadManager;

public class ThreadDemo extends DisplayObjectContainer
{
	public function ThreadDemo(args:String = ''):void
	{
		// 重要，使用线程方法前，如果需要指定线程所在代码的 swf 文件，则需要调用该方法
//		ThreadManager.init('ThreadMain.mbf');

		Stage.getStage().addEventListener(Event.ENTER_FRAME, onScheduleHandler);
	}

	private function onScheduleHandler(e:Event):void
	{
		ThreadManager.addCommand(new FileReadCommand('ThreadMain.swf'), onReadedCallback);
	}

	private function onReadedCallback(command:FileReadCommand):void
	{
		var content:ByteArray = command.execute();

		trace('[Main]', '文件读取结果：', content ? content.bytesAvailable : 'null');

//		content.clear();

		ThreadManager.addCommand(new FileWriteCommand('ThreadMain.mbf', content), onWritedCallback);
	}

	private function onWritedCallback(command:FileWriteCommand):void
	{
		trace('[Main]', '文件已写入：', command.path);
	}
}
}