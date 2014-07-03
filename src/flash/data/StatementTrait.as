package flash.data
{
	internal class StatementTrait
	{
		public var statement:SQLStatement;
		public var handler:Object;
		
		public function StatementTrait(statement:SQLStatement, handler:Object)
		{
			this.statement = statement;
			this.handler = handler;
		}
	}
}