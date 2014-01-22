/**
 * Created by bob on 14-1-3.
 */
package potato.concurrent
{
import core.system.Worker;

import flash.utils.ByteArray;

/**
 * 抽象命令类
 */
public class AbstractCommand
{
	private static var requestId:int = 0;

//	protected static var worker:Worker = Worker.current.isPrimordial ? ThreadManager.worker : Worker.current;

	private var _id:int;

	public function get id():int
	{
		if (!_id)
		{
			_id = requestId = requestId < ThreadConsts.MAX_REQUEST ? ++requestId : ThreadConsts.MIN_REQUEST;
		}

		return _id;
	}

	/**
	 * 设置 id
	 *
	 * 理论上，这个接口只是为反序列化命令对象时使用
	 *
	 * @param value
	 */
	public function set id(value:int):void
	{
		if (!_id && value >= ThreadConsts.MIN_REQUEST && value <= ThreadConsts.MAX_REQUEST)
			_id = value;
	}

	/**
	 * 检查当前是否在工作线程内
	 */
	protected static function get inTheWorker():Boolean
	{
		return !Worker.current.isPrimordial;
	}

	protected static function get worker():Worker
	{
		return inTheWorker ? Worker.current : ThreadManager.worker;
	}

	protected static function setSharedProperty(command:ICommand, value:ByteArray):void
	{
//		if (inTheWorker)
//		{
			worker.setSharedProperty(String(command.id), value);
			trace('[Thread]', '为命令 id', command.id, '存储了', value.bytesAvailable, '字节的 ByteArray 到工作线程中');
//		}
	}

	protected static function getSharedProperty(command:ICommand):ByteArray
	{
		var key:String = String(command.id);
		var result:ByteArray = worker.getSharedProperty(key);
		worker.setSharedProperty(key, null);

		trace('[Main]', '为命令 id', key, '从工作线程中加载了', result ? result.bytesAvailable : '0', '字节的 ByteArray');
		return result;
	}
}
}
