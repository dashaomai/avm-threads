package
{
import core.display.DisplayObjectContainer;
import core.display.Stage;
import core.events.Event;

import flash.utils.ByteArray;

import potato.concurrent.FileReadCommand;
import potato.concurrent.FileWriteCommand;

import potato.concurrent.ThreadManager;

public class Main extends DisplayObjectContainer
{
	public function Main(args:String = ''):void
	{
		Stage.getStage().addEventListener(Event.ENTER_FRAME, onScheduleHandler);
	}

	private function onScheduleHandler(e:Event):void
	{
		ThreadManager.addCommand(new FileReadCommand('ThreadMain.swf', 1), onReadedCallback);
	}

	private function onReadedCallback(command:FileReadCommand):void
	{
		var content:ByteArray = command.execute();

		trace('[Main]', '文件读取结果：', content ? content.bytesAvailable : 'null');

		content.clear();

		ThreadManager.addCommand(new FileWriteCommand('ThreadMain.mbf', content), onWritedCallback);
	}

	private function onWritedCallback(command:FileWriteCommand):void
	{
		trace('[Main]', '文件已写入：', command.path);
	}
}
}