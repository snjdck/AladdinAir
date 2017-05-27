package flash.data
{
	import flash.errors.SQLError;
	import flash.events.SQLEvent;
	import flash.filesystem.File;
	import flash.net.Responder;
	
	import stdlib.common.copyProps;

	final public class Database
	{
		private const statementCache:Vector.<StatementTrait> = new Vector.<StatementTrait>();
		private var connection:SQLConnection;
		
		public function Database(path:String)
		{
			connection = new SQLConnection();
			connection.addEventListener(SQLEvent.OPEN, __onOpen);
			connection.openAsync(new File(path), SQLMode.UPDATE);
		}
		
		private function __onOpen(evt:SQLEvent):void
		{
			flushCache();
		}
		
		private function flushCache():void
		{
			while(connection.connected && statementCache.length > 0){
				var trait:StatementTrait = statementCache.shift();
				executeImpl(trait.statement, trait.handler);
			}
		}
		
		public function execute(text:String, handler:Object, params:Object=null, itemClass:Class=null):void
		{
			var statement:SQLStatement = createStatement(text, params, itemClass);
			if(connection.connected){
				executeImpl(statement, handler);
			}else{
				statementCache.push(new StatementTrait(statement, handler));
			}
		}
		
		private function executeImpl(statement:SQLStatement, handler:Object):void
		{
			function onResponse(result:Object):void
			{
				if(result is SQLError){
					$lambda.call(handler, false, result);
				}else{
					$lambda.call(handler, true, result.data);
				}
			}
			statement.execute(-1, new Responder(onResponse, onResponse));
		}
		
		private function createStatement(text:String, params:Object, itemClass:Class):SQLStatement
		{
			var statement:SQLStatement = new SQLStatement();
			statement.sqlConnection = connection;
			statement.itemClass = itemClass;
			statement.text = text;
			statement.clearParameters();
			copyProps(statement.parameters, params);
			return statement;
		}
	}
}