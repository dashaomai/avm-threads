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
	 * 命令的 Id 编号
	 *
	 * Id 是介于 ThreadConsts.MIN_REQUEST 到 ThreadConsts.MAX_REQUEST 之间的整数，
	 * 系统的目标是保证不同的 ICommand 实例，Id 也不相同。
	 * 它是循环使用的，这样如果有一项操作特别慢，id 轮转一圈后，有可能导致前一命令的执行无效化。
	 */
	function get id():int;

	/**
	 * 命令类型
	 *
	 * 每创建一个命令对象，都可以到 CommandType 类里注册一个新的编号，一个编号代表一种命令。
	 * 这是为了在需要某个命令的具体类型时，不需要转型，而直接通过 type 就可以判断。
	 */
	function get type():int;

	/**
	 * 命令优先级
	 *
	 * 工作线程处理时会先按优先级进行排序后，再轮流处理各命令对象
	 * 它的默认值为零，可以指定大于或小于
	 */
	function get priority():int;

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
