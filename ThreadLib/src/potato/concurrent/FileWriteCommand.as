/**
 * Created by bob on 14-1-20.
 */
package potato.concurrent
{
import core.filesystem.File;

import flash.utils.ByteArray;

/**
 * 将字节流保存到指定路径的命令
 */
public class FileWriteCommand extends AbstractCommand implements ICommand
{
	public var path:String;

	public function FileWriteCommand(path:String = '', content:ByteArray = null):void
	{
		if (content && path && !inTheWorker)
		{
			this.path = path;

			content.position = 0;
			content.shareable = true;
			setSharedProperty(this, content);
		}
	}

	public function get type():int
	{
		return CommandType.FILE_WRITE;
	}

	public function execute(...params):*
	{
		if (inTheWorker)
		{
			trace('[Thread] Begin to write bytes into path', path);
			var content:ByteArray = getSharedProperty(this);
			File.writeByteArray(path, content);
			content.clear();
		}
	}
}
}
