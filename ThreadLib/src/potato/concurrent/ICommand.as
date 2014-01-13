/**
 * Created by bob on 14-1-3.
 */
package potato.concurrent
{
public interface ICommand
{
	function get id():int;
	function get type():int;

	function execute(...params:Array):*;
}
}
