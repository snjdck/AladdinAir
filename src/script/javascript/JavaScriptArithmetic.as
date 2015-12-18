package script.javascript
{
	import blockly.SyntaxTreeFactory;
	import blockly.runtime.FunctionProvider;
	import blockly.runtime.Interpreter;
	import blockly.util.FunctionProviderHelper;
	
	import snjdck.agalc.arithmetic.Arithmetic;
	import snjdck.agalc.arithmetic.Lexer;
	import snjdck.agalc.arithmetic.node.Node;
	import snjdck.agalc.arithmetic.node.NodeType;
	import snjdck.agalc.arithmetic.node.impl.NodeFactory;
	import snjdck.agalc.arithmetic.rule.ILexRule;
	import snjdck.agalc.arithmetic.rule.LexRuleFactory;
	
	internal class JavaScriptArithmetic extends Arithmetic
	{
		private var ruleList:ILexRule;
		private var interpreter:Interpreter;
		
		public function JavaScriptArithmetic()
		{
			super(null);
			var provider:FunctionProvider = new FunctionProvider();
			FunctionProviderHelper.InitMath(provider);
			interpreter = new Interpreter(provider);
			ruleList = LexRuleFactory.CreateScriptArithmeticRuleList();
		}
		
		private function nodeToArray(node:Node):Array
		{
			var result:Array = [];
			while(node != null){
				result.push(nodeToBlock(node));
				node = node.nextSibling;
			}
			return result;
		}
		
		private function nodeToBlock(node:Node):Object
		{
			switch(node.type)
			{
				case NodeType.NUM:
					return SyntaxTreeFactory.NewNumber(node.realValue);
					break;
				case NodeType.VAR_ID:
					return SyntaxTreeFactory.GetVar(node.realValue);
				case NodeType.OP_ADD:
				case NodeType.OP_SUB:
				case NodeType.OP_MUL:
				case NodeType.OP_DIV:
				case NodeType.OP_GREATER:
				case NodeType.OP_GREATER_EQUAL:
				case NodeType.OP_LESS:
				case NodeType.OP_LESS_EQUAL:
					return SyntaxTreeFactory.NewExpression(node.value, [
						nodeToBlock(node.leftChild),
						nodeToBlock(node.rightChild)
					]);
				case NodeType.OP_DOT:
					return SyntaxTreeFactory.NewExpression("getProp", [
						nodeToBlock(node.leftChild),
						SyntaxTreeFactory.NewString(node.rightChild.value)
					]);
				case NodeType.CALL_METHOD:
					return SyntaxTreeFactory.NewInvoke(nodeToBlock(node.firstChild), nodeToArray(node.rightChild), 1);
			}
			
			return null;
		}
		
		private function readStatementBlock(result:Array):Array
		{
			nodeList.accept(NodeType.BRACES_LEFT);
			while(nodeList.first().type != NodeType.BRACES_RIGHT){
				readStatement(result);
			}
			nodeList.next();
			return result;
		}
		
		private function readStatement(result:Array):Array
		{
			switch(nodeList.first().type){
				case NodeType.BRACES_LEFT:
					readStatementBlock(result);
					break;
				case NodeType.KEYWORD_VAR:
					nodeList.next();
					var varName:String = nodeList.accept(NodeType.VAR_ID).value;
					if(nodeList.expect(NodeType.OP_ASSIGN)){
						nodeList.next();
						result.push(SyntaxTreeFactory.NewVar(varName, nodeToBlock(expression())));
					}else{
						result.push(SyntaxTreeFactory.NewVar(varName, SyntaxTreeFactory.NewString(null)));
					}
					break;
				case NodeType.KEYWORD_IF:
					nodeList.next();
					result.push(SyntaxTreeFactory.NewIf(nodeToBlock(equ()), readStatement([])));
					break;
				case NodeType.KEYWORD_WHILE:
					nodeList.next();
					result.push(SyntaxTreeFactory.NewWhile(nodeToBlock(equ()), readStatement([])));
					break;
				case NodeType.VAR_ID:
					var testNode:Node = expression();
					result.push(nodeToBlock(testNode));
					trace(testNode);
					/*
					var varName:String = nodeList.next().value;
					if(nodeList.expect(NodeType.OP_ASSIGN)){
						nodeList.next();
						result.push(toValue(expression()));
						result.push(SyntaxTreeFactory.SetVar(varName));
					}else if(nodeList.expect(NodeType.PARENTHESES_LEFT)){
						nodeList.next();
						result.push(SyntaxTreeFactory.GetVar(varName));
						var argList:Array = [];
						while(nodeList.first().type != NodeType.PARENTHESES_RIGHT){
							argList.push(toValue(expression()));
							if(nodeList.expect(NodeType.COMMA)){
								nodeList.next();
							}else{
								break;
							}
						}
						nodeList.accept(NodeType.PARENTHESES_RIGHT);
						result.push(SyntaxTreeFactory.NewInvoke(argList, 0));
					}else if(nodeList.expect(NodeType.OP_DOT)){
						nodeList.next();
						result.push(SyntaxTreeFactory.GetVar("getProp"));
						result.push(SyntaxTreeFactory.GetVar(varName));
						result.push(SyntaxTreeFactory.NewExpression("getProp", [
							SyntaxTreeFactory.GetVar(varName)]),
							SyntaxTreeFactory.NewString(nodeList.accept(NodeType.VAR_ID).value)
						);
					}
					*/
					break;
				case NodeType.KEYWORD_FUNC:
					nodeList.next();
					var funcName:String;
					if(!nodeList.expect(NodeType.PARENTHESES_LEFT)){
						funcName = nodeList.accept(NodeType.VAR_ID).value;
					}
					nodeList.accept(NodeType.PARENTHESES_LEFT);
					var argNameList:Array = readArgNameList();
					nodeList.accept(NodeType.PARENTHESES_RIGHT);
					var funcCode:Array = readStatementBlock([]);
					if(funcName != null){
						result.push(SyntaxTreeFactory.NewVar(funcName,
							SyntaxTreeFactory.NewFunction(argNameList, funcCode))
						);
					}
					break;
			}
			return result;
		}
		
		private function readArgNameList():Array
		{
			var node:Node = readValueList(NodeType.PARENTHESES_RIGHT, readVarId);
			var result:Array = [];
			while(node != null){
				result.push(node.value);
				node = node.nextSibling;
			}
			return result;
		}
		
		private function readVarId():Node
		{
			return nodeList.accept(NodeType.VAR_ID);
		}
		
		override public function parse(source:String):Node
		{
			var codeList:Array = [];
			Lexer.Parse(source, ruleList, nodeList);
			while(nodeList.first().type != NodeType.EOF){
				readStatement(codeList);
			}
			nodeList.accept(NodeType.EOF);
			trace(interpreter.compile(codeList).join("\n"));
			interpreter.execute(codeList);
			return null;
		}
		
		override public function expression():Node
		{
			return assign();
		}
		
		private function assign():Node
		{
			return matchRight(equ, [NodeType.OP_ASSIGN]);
		}
		
		private function equ():Node{
			return matchLeft(com, [NodeType.OP_EQUAL, NodeType.OP_NOT_EQUAL]);
		}
		
		private function com():Node{
			return matchLeft(e, [NodeType.OP_GREATER, NodeType.OP_GREATER_EQUAL, NodeType.OP_LESS, NodeType.OP_LESS_EQUAL]);
		}
		
		private function e():Node{
			return matchLeft(t, [NodeType.OP_ADD, NodeType.OP_SUB]);
		}
		
		private function t():Node{
			return matchLeft(unitary, [NodeType.OP_MUL, NodeType.OP_DIV]);
		}
		
		private function unitary():Node{
			if(nodeList.expect(NodeType.OP_SUB)){
				return calcute(NodeFactory.Create(NodeType.NUM, "0"), nodeList.next(), unitary());
			}
			if(nodeList.expect(NodeType.OP_ADD)){
				nodeList.next();
				return unitary();
			}
			return f();
		}
		
		private function f():Node{
			return matchRight(dot, [NodeType.OP_POW]);
		}
		
		private function dot():Node{
			var a:Node = val();
			while(nodeList.expect(NodeType.OP_DOT)){
				a = calcute(a, nodeList.next(), nodeList.accept(NodeType.VAR_ID));
			}
			if(nodeList.expect(NodeType.PARENTHESES_LEFT)){
				nodeList.next();
				var argNode:Node = readValueList(NodeType.PARENTHESES_RIGHT, expression);
				nodeList.accept(NodeType.PARENTHESES_RIGHT);
				return calcute(a, NodeFactory.Create(NodeType.CALL_METHOD), argNode);
			}
			return a;
		}
		
		private function val():Node
		{
			switch(nodeList.first().type){
				case NodeType.NUM:
				case NodeType.VAR_ID:
					return nodeList.next();
				case NodeType.PARENTHESES_LEFT:
					nodeList.accept(NodeType.PARENTHESES_LEFT);
					var val:Node = equ();
					nodeList.accept(NodeType.PARENTHESES_RIGHT);
					return val;
				default:
					throw new Error("error input!");
			}
		}
	}
}