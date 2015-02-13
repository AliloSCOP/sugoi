/*
 * Copyright (c) 2008, TouchMyPixel & contributors
 * Original author : Tony Polinelli <tonyp@touchmypixel.com> 
 * Contributers: Tarwin Stroh-Spijer 
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   - Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   - Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE TOUCH MY PIXEL & CONTRIBUTERS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE TOUCH MY PIXEL & CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 */


package sugoi.form.validators;

import sugoi.form.Validator;
import poko.utils.StringTools2;

class ListValidator extends Validator
{
	public var list:Array<Dynamic>;
	public var mode:ListValidatorMode;
	
	public var errorAllow:String;
	public var errorDeny:String;
	
	public function new(?mode:ListValidatorMode)
	{
		super();
		
		errorAllow = "Only the values %s are allowed.";
		// this is used for the complete list of denied values
		//errorDeny = "The values %s are not allowed.";
		errorDeny = "The value '%s' is not allowed.";
		
		this.mode = mode != null ? mode : ListValidatorMode.ALLOW;
	}
	
	override public function isValid(value:Dynamic):Bool
	{
		super.isValid(value);
		
		var valueExists = Lambda.has(list, value);
		var valid = (mode == ListValidatorMode.ALLOW) ? valueExists : !valueExists;
		if (!valid) {
			// this one returns a list of denied values, which is nice, but though thought it might be a security risk somehow?
			//errors.push(StringTools2.printf(mode == ListValidatorMode.ALLOW ? errorAllow : errorDeny, [joinAsSentence(list, "'")]));
			if (mode == ListValidatorMode.ALLOW) {
				errors.push(StringTools2.printf(errorAllow, [joinAsSentence(list, "'")]));
			}else {
				errors.push(StringTools2.printf(errorDeny, [value]));
			}
		}
		return valid;
	}
	
	private function joinAsSentence(a:Array<Dynamic>, ?wrapWith:String):String
	{
		if (wrapWith != null) {
			for(i in 0...a.length)
				a[i] = wrapWith + a[i] + wrapWith;
		}
		var e = a.pop();
		var s = a.join(", ") + " and " + e;
		return s;
	}
}

enum ListValidatorMode
{
	ALLOW;
	DENY;
}

/*
	var v:ListValidator = new ListValidator(ListValidatorMode.ALLOW);
	var a:Array<Dynamic> = ["good", "bad", "stupid"];
	v.list = a;
	trace(v.isValid("good"));
	trace(v.errors);
	v.reset();
	v.list = a;
	trace(v.isValid("bad"));
	trace(v.errors);
	v.reset();
	v.list = a;
	trace(v.isValid("ugly"));
	trace(v.errors);
	v.reset();
*/