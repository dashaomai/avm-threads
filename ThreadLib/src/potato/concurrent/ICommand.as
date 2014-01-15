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
	 * 它是循环使用的，这样如果有一项操作特别慢，id 轮转一圈后，有可能导致前一命令的执行无效化。
	 */
	function get id():int;

	/**
	 * 命令类型
	 */
	function get type():int;

	/**
	 * 命令执行
	 *
	 * 作为穿越线程之间的命令对象，它的目的是执行自己所带的指令，随后返回结果。
	 *
	 * 通常来说，执行方法在主线程及工作线程内，都会执行，它们的行为结果是不同的。
	 * 工作线程内执行，是进行真正耗时的工作内容，例如：文件读取、寻路等。
	 *
	 * @param params        执行所需的各种参数
	 * @return              执行的结果（如果有的话）
	 */
	function execute(...params:Array):*;
}
}
