(function (win, doc) {
	'use strict';

	function print(txt) {
		console.log(txt);
	}

	function load(path, callback) {
		var isPathArray = Array.isArray(path),
			pathes = isPathArray ? path : [path],
			restScriptSize = pathes.length;

		var loadFunc = function (targetPath) {
			var testScriptEle = doc.createElement('script');
			testScriptEle.onload = function (evt) {
				doc.body.removeChild(testScriptEle);
				testScriptEle = null;

				restScriptSize--;
				if (restScriptSize <= 0) {
					callback();
				}
			};
			testScriptEle.src = targetPath;
			doc.body.appendChild(testScriptEle);
		};

		for (var i = 0, max = pathes.length; i < max; i++) {
			loadFunc(pathes[i]);
		}
	}

	function isFunction(f) {
		return typeof f === 'function';
	}

	function isEqualsArray(a1, a2) {
		if (a1.length !== a2.length) {
			return false;
		}

		for (var i = 0; i < a1.length; i++) {
			if (a1[i] !== a2[i]) {
				var isEql = false;
				

				if (isFunction(a1[i].equals)) {
					isEql = a1[i].equals(a2[i]);
				}
				
				if (Array.isArray(a1[i]) && Array.isArray(a2[i])) {
					isEql = isEqualsArray(a1[i], a2[i]);
				}

				
				if(!isEql){
					return false;
				}
			}
		}

		return true;
	}

	function isEquals(obj1, obj2) {
		if (obj1 === obj2) {
			return true;
		}

		if (isFunction(obj1.equals)) {
			return obj1.equals(obj2);
		}


		if (Array.isArray(obj1) && Array.isArray(obj2)) {
			return isEqualsArray(obj1, obj2);
		}

		return false;
	}

	function addAll(list, src) {
		for (var i = 0, len = src.length; i < len; i++) {
			list.push(src[i]);
		}
	}

	/**
	 * @todo
	 * Only JSONable object.
	 */
	function deepCopy(src) {
		return JSON.parse(JSON.stringify(src));
	}

	function Set(values) {
		this.dict = {};

		for (var i = 0; i < values.length; i++) {
			var val = values[i];
			this.dict[val.toString()] = true;
		}
	}

	Set.prototype = {
		equals: function (other) {
			if (other === undefined || other === null) {
				return false;
			}

			if (!(other instanceof Set)) {
				return false;
			}

			for (var i = 0; i < other.length; i++) {
				var val = other[i];

				if (!this.dict[val]) {
					return false;
				}
			}

			return true;
		}
	};

	function assertEquals(expected, actual) {
		print('start test');

		if (this.isEquals(expected, actual)) {
			print('OK');
		} else {
			print('NG');
			print('expected ... ' + expected.toString());
			print('actual ... ' + actual.toString());
			throw new Error('Fail tests.');
		}
	}

	win.gomapre = {
		print: print,
		load: load,
		isEquals: isEquals,
		assertEquals: assertEquals,
		addAll: addAll,
		Set: Set
	};
}(window, document));
