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

class DateValidator extends Validator
{
	//public static var EMAIL_REGEX : EReg = "([0-9]{4})[-\.[:space:]]([0-9]{2})[-\.[:space:]]([0-9]{2})";
	public var format:EReg;
	
	public var minDate:Date;
	public var maxDate:Date;
	
	public var errorDateOutOfRange:String;
	public var errorDateNotValid:String;
	public var errorDateNotExist:String;
	
	public function new(?minDate:Date, ?maxDate:Date)
	{
		super();
		
		format = new EReg("[0-9]{4}-[0-9]{2}-[0-9]{2}", null);
		
		errorDateOutOfRange = "Must be between %s and %s";
		errorDateNotValid = "Is not in the correct format. YYYY-MM-DD is required.";
		
		if (minDate != null) this.minDate = minDate;
		if (maxDate != null) this.maxDate = maxDate;
	}
	
	override public function isValid(value:Dynamic):Bool
	{
		var valid = true;
		var d:Date;
		
		// value is date
		if (Type.getClass(value) == Date){
			d = value;
		// value conforms to format, convert to date
		}else if (Type.getClass(value) == String && format.match(value)) {
			d = Date.fromString(value);
		}else {
			errors.add(errorDateNotValid);
			return false;
		}
		
		// check date range
		if (minDate != null){
			if (d.getTime() < minDate.getTime())
				valid = false;
		}
		
		if (maxDate != null){
			if (d.getTime() > maxDate.getTime())
				valid = false;	
		}
		
		// date must be out of range if invalid at this point
		if (!valid)
			errors.add(StringTools2.printf(errorDateOutOfRange, [dateOnly(minDate), dateOnly(maxDate)]));
		
		return valid;
	}
	
	private function dateOnly(d:Date):String
	{
		return StringTools.lpad(Std.string(d.getFullYear()), "0", 4) + "-" + StringTools.lpad(Std.string(d.getMonth()), "0", 2) + "-" + StringTools.lpad(Std.string(d.getDate()), "0", 2);
	}
}

/*
	var v:DateValidator = new DateValidator(Date.fromString("1981-12-09"), Date.fromString("2030-11-11"));
	
	// -------------------------------------------------
	// check input
	trace("<br /><br />INPUT<br />");		
	
	v.reset();
	trace(true);
	trace(v.isValid("1981-12-09"));
	trace(v.errors);
	
	v.reset();
	trace(false);
	trace(v.isValid("x981-12-09"));
	trace(v.errors);
	
	v.reset();
	trace(false);
	trace(v.isValid("1985-90-90"));
	trace(v.errors);		
	
	// -------------------------------------------------
	// check ranges
	trace("<br /><br />RANGES<br />");
	
	v.reset();
	trace(true);
	trace(v.isValid(Date.fromString("1981-12-09")));
	trace(v.errors);
	
	v.reset();
	trace(false);
	trace(v.isValid(Date.fromString("1981-12-08")));
	trace(v.errors);

	v.reset();
	trace(true);
	trace(v.isValid(Date.now()));
	trace(v.errors);
	
	v.reset();
	trace(true);
	trace(v.isValid(Date.fromString("2030-11-11")));
	trace(v.errors);
	
	v.reset();
	trace(false);
	trace(v.isValid(Date.fromString("2030-11-12")));
	trace(v.errors);
*/