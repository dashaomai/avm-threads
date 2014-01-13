/**
 * Created by bob on 14-1-3.
 */
package potato.concurrent
{
import core.display.Stage;
import core.events.Event;
import core.filesystem.File;
import core.system.Worker;
import core.system.WorkerDomain;

import flash.concurrent.Mutex;
import flash.net.registerClassAlias;
import flash.utils.ByteArray;

registerClassAlias('concurrent.FileReadCommand', FileReadCommand);

public class ThreadManager
{
	private static var _worker:Worker;

	private static const callbacksDic:Object = {};

	private static var _commandsToWorker:Array;
	private static var _commandsToMain:Array;

	private static var _mutexToWorker:Mutex;
	private static var _mutexToMain:Mutex;

	public static function get worker():Worker
	{
		return _worker;
	}

	public static function init(path:String = 'ThreadMain.swf'):void {
		if (!_worker)
		{
			_worker = WorkerDomain.current.createWorkerFromByteArray(File.readByteArray(path));

			_mutexToWorker = new Mutex();
			_mutexToMain = new Mutex();

			_commandsToWorker = [];
			_commandsToMain = [];

			_worker.setSharedProperty(ThreadConsts.MUTEX2WORKER, _mutexToWorker);
			_worker.setSharedProperty(ThreadConsts.MUTEX2MAIN, _mutexToMain);

			_worker.setSharedProperty(ThreadConsts.COMMANDS2WORKER, _commandsToWorker);
			_worker.setSharedProperty(ThreadConsts.COMMANDS2MAIN, _commandsToMain);

			_worker.start();

			Stage.getStage().addEventListener(Event.ENTER_FRAME, onScheduleHandler);
		}
	}

	private static function onScheduleHandler(e:Event):void
	{
		if (!_mutexToMain.tryLock())
		{
			trace('尝试给主线程队列加锁失败！');
			return;
		}

		_commandsToMain = _worker.getSharedProperty(ThreadConsts.COMMANDS2MAIN) || _commandsToMain;
		if (_commandsToMain.length)
			_worker.setSharedProperty(ThreadConsts.COMMANDS2MAIN, null);
		_mutexToMain.unlock();

		if (_commandsToMain.length)
		{
//			trace('[Main]:', JSON.stringify(_commandsToMain));

			for each (var command:ICommand in _commandsToMain)
			{
				var ba:ByteArray = command.execute();

				var cb:Function = callbacksDic[command.id];
				if (cb) {
					delete callbacksDic[command.id];

					cb(ba);
				} else {
					trace('We lost the callback for command id:', command.id);
				}
			}

			_commandsToMain.length = 0;
		}

		if (_commandsToWorker.length && _mutexToWorker.tryLock())
		{
			var commands:Array = _worker.getSharedProperty(ThreadConsts.COMMANDS2WORKER) || [];
			_worker.setSharedProperty(ThreadConsts.COMMANDS2WORKER, commands.concat(_commandsToWorker));
			_mutexToWorker.unlock();

			commands.length = 0;
			_commandsToWorker.length = 0;
		}
	}

	public static function addCommand(command:ICommand, callback:Function):Boolean
	{
		var result:Boolean = false;
		if (callbacksDic[command.id])
		{
			trace('相同 id#', command.id, '的回调请求已经注册，前一回调将被覆盖');
			result = true;
		}

		callbacksDic[command.id] = callback;

		_commandsToWorker.push(command);

		return result;
	}
}
}
