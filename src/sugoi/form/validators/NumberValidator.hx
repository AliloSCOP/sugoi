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

class NumberValidator extends Validator
{
	public var isInt:Bool;
	public var min:Float;
	public var max:Float;
	
	public var errorNumber:String;
	public var errorInt:String;
	public var errorMin:String;
	public var errorMax:String;
	
	public function new(min:Float=0, max:Float=999999999999, isInt:Bool=false) 
	{
		super();
		
		this.min = min;
		this.max = max;
		this.isInt = isInt;
		
		errorNumber = "Must be a number";
		errorInt = "Must be an integer";
		errorMin = "Minimum number %s";
		errorMax = "Maximum number %s";
	}
	
	override public function isValid(value:Dynamic):Bool
	{
		super.isValid(value);
		
		var valid = true;
		var f = Std.parseFloat(Std.string(value));
		var i = Std.int(f);
		
		if (Math.isNaN(f))
		{
			errors.add(errorNumber);
			valid = false;
		}else{
		
			if (isInt && i != f) {
				errors.add(errorInt);
				valid = false;
			}
			
			var n:Float = isInt ? i : f;
			
			if (n < min) {
				errors.add(StringTools2.printf(errorMin, [min]));
				valid = false;
			}else if (n > max) {
				errors.add(StringTools2.printf(errorMax, [max]));
				valid = false;
			}
		}
		
		return valid;
	}
	
}

/*

	var v:NumberValidator = new NumberValidator();
	v.isInt = false;
	v.min = -5;
	v.max = 10.55;
	trace(v.validate(5));
	trace(v.errors);
	v.reset();
	trace(v.validate( -6));
	trace(v.errors);
	v.reset();
	trace(v.validate( -3));
	trace(v.errors);
	v.reset();
	trace(v.validate(11.5));
	trace(v.errors);
	v.reset();
	
*/