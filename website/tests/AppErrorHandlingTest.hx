package tests;

import js.lib.Promise;
import utest.Assert;
import utest.Async;
import utest.Test;

class AppErrorHandlingTest extends Test {
	function testWithAsyncErrorHandlerWhenHandlerRejectsCallsNextWithError(async:Async) {
		var expectedError = "test-error";
		var wrappedHandler = App.withAsyncErrorHandler(function(req, res, next) {
			return new Promise(function(resolve, reject) {
				reject(expectedError);
			});
		});

		wrappedHandler(givenRequest(), cast givenResponse(), function(?error:Dynamic):Void {
			Assert.equals(expectedError, error);
			async.done();
		});
	}

	function testHandleUnhandledErrorSets500AndEndsResponse() {
		var response = givenResponse();
		var responseBody:Dynamic = null;
		response.end = function(?body:Dynamic):Void {
			responseBody = body;
		};

		App.handleUnhandledError("test-error", givenRequest(), cast response, function(?error:Dynamic):Void {});

		Assert.equals(500, response.statusCode);
		Assert.equals("Internal Server Error", responseBody);
	}

	function givenRequest():Dynamic {
		return {
			params: {},
			locals: {},
			query: {},
			path: "/missions",
			body: {},
			cookies: {},
			originalUrl: "/missions",
			baseUrl: ""
		};
	}

	function givenResponse():Dynamic {
		return {
			locals: {},
			set: function(headers:Dynamic):Void {},
			end: function(?body:Dynamic):Void {},
			redirect: function(path:String):Void {},
			statusCode: 200,
			headersSent: false,
		};
	}
}
