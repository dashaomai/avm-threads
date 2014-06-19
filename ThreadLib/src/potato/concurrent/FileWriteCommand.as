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

	public function FileWriteCommand(path:String = '', content:ByteArray = null, priority:int = 0):void
	{
		if (content && path)
		{
			this.path = path;

			content.position = 0;
			content.shareable = true;
			setSharedProperty(this, content);

			super(priority);
		}
	}

	public function get type():int
	{
		return CommandType.FILE_WRITE;
	}

	public function execute(...params:Array):*
	{
		if (inTheWorker)
		{
			var content:ByteArray = getSharedProperty(this);
			var success:Boolean = !!content;

			if (success)
			{
				try
				{
					File.writeByteArray(path, content);
				}
				catch (err:Error)
				{
					success = false;
				}
			}

			trace('[Thread] 已将', success ? content.bytesAvailable : '0', '字节数据存储到文件', path, '当中');
			if (success) content.clear();
		}
	}
}
}
