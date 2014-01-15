/**
 * Created by bob on 14-1-3.
 */
package potato.concurrent
{
/**
 * 命令接口
 *
 * 命令在多线程语境下，是可以携带一些必要的属性，穿梭于线程之间，
 * 并通过自身的执行调用，完成各种操作。
 */
public interface ICommand
{
	/**
	 * 命令的 id 值
	 *
	 * id 是介于 ThreadConsts.MIN_REQUEST 到 ThreadConsts.MAX_REQUEST 之间的整数，
	 * 它是循环使用的，这样如果有一项操作特别慢，id 轮转一圈后，有可能导致
	 */
	function get id():int;
	function get type():int;

	function execute(...params:Array):*;
}
}
