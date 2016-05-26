
// Author URL: http://bikramkawan.com.np
// Email : bikramkawan@gmail.com
// Version: 18.03.2016



$(function(){
	
	var currentValue = $('#currentValue');
	$('#defaultSlider').change(function(){
	    currentValue.html(this.value);
	   // console.log(defaultSlider.value);
	

	});
	
	// Trigger the event on load, so
	// the value field is populated:
	
	$('#defaultSlider').change();
	
});