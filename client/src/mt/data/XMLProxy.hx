/*
 * Copyright (C)2005-2019 Haxe Foundation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */
 package mt.data;
 /**
     This proxy can be inherited with an XML file name parameter.
     It will	only allow access to fields which corresponds to an "id" attribute
     value in the XML file :
     ```haxe
     class MyXml extends mt.data.XMLProxy<"my.xml", MyStructure> {
     }
     var h = new haxe.ds.StringMap<MyStructure>();
     // ... fill h with "my.xml" content
     var m = new MyXml(h.get);
     trace(m.myNode.structField);
     // Access to "myNode" is only possible if you have an id="myNode" attribute
     // in your XML, and completion works as well.
     ```
 **/
 class XMLProxy<Const, T> {
	dynamic function __f(s:String):T {
		return null;
	}

	public function new(f:String->T) {
		this.__f = f;
	}

	public function resolve(k:String):T {
		return __f(k);
	}
}
