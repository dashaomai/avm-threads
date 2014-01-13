/**
 * Created by bob on 14-1-3.
 */
package potato.concurrent
{
import core.system.Worker;

import flash.utils.ByteArray;

public class AbstractCommand
{
	private static var requestId:int = 0;

	private var _id:int;

	public function get id():int
	{
		if (!_id)
		{
			_id = requestId = requestId < ThreadConsts.MAX_REQUEST ? ++requestId : ThreadConsts.MIN_REQUEST;
		}

		return _id;
	}

	public function set id(value:int):void
	{
		if (!_id && value >= ThreadConsts.MIN_REQUEST && value <= ThreadConsts.MAX_REQUEST)
			_id = value;
	}

	protected static function inTheWorker(command:ICommand):Boolean
	{
		return (!Worker.current.isPrimordial
				&& command.id >= ThreadConsts.MIN_REQUEST
				&& command.id <= ThreadConsts.MAX_REQUEST);
	}

	protected static function setSharedProperty(command:ICommand, value:ByteArray):void
	{
		if (inTheWorker(command))
		{
			Worker.current.setSharedProperty(String(command.id), value);
			trace('[Thread]', 'Set ByteArray for id', command.id, 'is', value.bytesAvailable, 'bytes,');
		}
	}

	protected static function getSharedProperty(command:ICommand):ByteArray
	{
		var key:String = String(command.id);
		var result:ByteArray = ThreadManager.worker.getSharedProperty(key);
		ThreadManager.worker.setSharedProperty(key, null);

		trace('[Main]', 'Get ByteArray for id', key, 'is', result ? result.bytesAvailable : '0', 'bytes.');
		return result;
	}
}
}
