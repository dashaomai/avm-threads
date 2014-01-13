/**
 * Created by bob on 14-1-3.
 */
package potato.concurrent
{
public class ThreadConsts
{
	public static const COMMANDS2WORKER:String = 'commands_to_worker';
	public static const COMMANDS2MAIN:String = 'commands_to_main';

	public static const MUTEX2WORKER:String = 'mutex_to_worker';
	public static const MUTEX2MAIN:String = 'mutex_to_main';

	public static const SLEEP_MS:int = 30;

	public static const MIN_REQUEST:int = 1;
	public static const MAX_REQUEST:int = 256;
}
}
