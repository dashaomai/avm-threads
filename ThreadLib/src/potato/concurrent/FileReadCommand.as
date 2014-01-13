/**
 * Created by bob on 14-1-3.
 */
package potato.concurrent
{
import core.filesystem.File;

import flash.utils.ByteArray;

public class FileReadCommand extends AbstractCommand implements ICommand
{
	public var path:String;

	public function FileReadCommand(path:String = ''):void
	{
		if (path)
		{
			this.path = path;
		}
	}

	public function get type():int
	{
		return CommandType.FILE_READ;
	}

	public function execute(...params:Array):*
	{
		if (inTheWorker(this))
		{
			var bytes:ByteArray = File.readByteArray(path);
			bytes.shareable = true;

			setSharedProperty(this, bytes);
		}
		else
		{
			return getSharedProperty(this);
		}
	}
}
}
