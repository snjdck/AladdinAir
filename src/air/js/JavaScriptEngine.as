package air.js
{
	import flash.html.HTMLLoader;

	public class JavaScriptEngine
	{
		private var dock:HTMLLoader;
		
		public function JavaScriptEngine()
		{
			dock = new HTMLLoader();
			dock.placeLoadStringContentInApplicationSandbox = true;
		}
		
		public function get window():Object
		{
			return dock.window;
		}
		
		public function eval(code:String):void
		{
			dock.window.eval(code);
		}
	}
}