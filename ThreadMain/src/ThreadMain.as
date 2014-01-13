package
{
import core.display.DisplayObjectContainer;
import core.system.System;
import core.system.Worker;

import flash.concurrent.Mutex;
import flash.net.registerClassAlias;

import potato.concurrent.FileReadCommand;

import potato.concurrent.ICommand;

import potato.concurrent.ThreadConsts;

registerClassAlias('concurrent.FileReadCommand', FileReadCommand);

public class ThreadMain extends DisplayObjectContainer
{
    public function ThreadMain(args:String = ''):void
    {
	    var worker:Worker = Worker.current;

	    // 不在主线程内执行
	    if (worker.isPrimordial)
	        return;

	    var mutexToWorker:Mutex = worker.getSharedProperty(ThreadConsts.MUTEX2WORKER);
	    var mutexToMain:Mutex = worker.getSharedProperty(ThreadConsts.MUTEX2MAIN);

	    var commandsToWorker:Array = [];       // 由 ICommand 构成的数组
	    var commandsToMain:Array = [];

	    while (true)
	    {
		    mutexToWorker.lock();
		    commandsToWorker = worker.getSharedProperty(ThreadConsts.COMMANDS2WORKER) || commandsToWorker;
		    if (commandsToWorker.length)
		        worker.setSharedProperty(ThreadConsts.COMMANDS2WORKER, null);
		    mutexToWorker.unlock();

		    if (commandsToWorker.length)
		    {
			    trace('[Thread]', '工作线程队列收到以下命令:', JSON.stringify(commandsToWorker));

			    for each (var command:ICommand in commandsToWorker)
			    {
				    command.execute();
			    }

			    mutexToMain.lock();
			    commandsToMain = worker.getSharedProperty(ThreadConsts.COMMANDS2MAIN) || commandsToMain;
			    worker.setSharedProperty(ThreadConsts.COMMANDS2MAIN, commandsToMain.concat(commandsToWorker));
			    mutexToMain.unlock();

			    commandsToWorker.length = 0;
			    commandsToMain.length = 0;
		    }

		    System.sleep(ThreadConsts.SLEEP_MS);
	    }
    }
}
}