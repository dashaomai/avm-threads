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
registerClassAlias('concurrent.FileWriteCommand', FileWriteCommand);

/**
 * 线程管理者
 *
 * 管理者是运行在主线程内，对工作线程进行管理和通讯的工具类
 */
public class ThreadManager
{
	private static var _worker:Worker;

	private static const callbacksDic:Vector.<Function> = new Vector.<Function>();

	private static var _commandsToWorker:Array;
	private static var _commandsToMain:Array;
	// 为防止批量命令一口气流向外部回调，特别设计 to be continue 的命令数组，以便控制外流的速度
	private static var _commandsToBeContinue:Array;

	private static var _mutexToWorker:Mutex;
	private static var _mutexToMain:Mutex;

	public static function get worker():Worker
	{
		return _worker;
	}

	/**
	 * 初始化工作线程
	 *
	 * 当工作线程不存在时，才会创建并初始化之
	 *
	 * @param path      包含了编译后线程代码的文件路径（可选）
	 */
	public static function init(path:String = 'ThreadMain.swf'):void {
		if (!_worker)
		{
			_worker = WorkerDomain.current.createWorkerFromByteArray(File.readByteArray(path));

			_mutexToWorker = new Mutex();
			_mutexToMain = new Mutex();

			_commandsToWorker = [];
			_commandsToMain = [];
			_commandsToBeContinue = [];

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
			trace('[Main] 尝试给主线程队列加锁失败！');
			return;
		}

		_commandsToMain = _worker.getSharedProperty(ThreadConsts.COMMANDS2MAIN) || _commandsToMain;
		if (_commandsToMain.length)
			_worker.setSharedProperty(ThreadConsts.COMMANDS2MAIN, null);
		_mutexToMain.unlock();

		if (_commandsToMain.length)
		{
			trace('[Main]', '主线程队列收到以下命令:', JSON.stringify(_commandsToMain));

			_commandsToBeContinue = _commandsToBeContinue.concat(_commandsToMain);
			_commandsToMain.length = 0;

			trace('[Main]', '等待处理的队列为：', JSON.stringify(_commandsToBeContinue));
		}

		if (_commandsToWorker.length && _mutexToWorker.tryLock())
		{
			var commands:Array = _worker.getSharedProperty(ThreadConsts.COMMANDS2WORKER) || [];
			_worker.setSharedProperty(ThreadConsts.COMMANDS2WORKER, commands.concat(_commandsToWorker));
			_mutexToWorker.unlock();

			commands.length = 0;
			_commandsToWorker.length = 0;
		}

		if (_commandsToBeContinue.length)
		{
			// 一次只处理一条指令并回调出去
			var command:ICommand = _commandsToBeContinue.shift();
			var cb:Function = callbacksDic[command.id];
			if (cb) {
				delete callbacksDic[command.id];

				cb(command);
			} else {
				trace('[Main]', '找不到针对以下命令 id 的回调函数：', command.id);
			}

		}
	}

	/**
	 * 添加一个命令
	 *
	 * 通过该方法，可将命令对象序列化传递到工作线程内，并指定在完成后调用的回调函数。
	 *
	 * @param command       要添加的命令
	 * @param callback      完成后调用的回调函数。该函数形式为：function(command:ICommand)
	 * @return              是否覆盖了以前注册过相同 id 的回调
	 */
	public static function addCommand(command:ICommand, callback:Function = null):Boolean
	{
		var result:Boolean = false;
		if (callbacksDic[command.id])
		{
			trace('[Main]', '相同命令 id:', command.id, '的回调请求已经注册，前一回调将被覆盖');
			result = true;
		}

		trace('before', JSON.stringify(callbacksDic));

		callbacksDic[command.id] = callback;

		trace('after', JSON.stringify(callbacksDic));
		_commandsToWorker.push(command);

		return result;
	}
}
}
