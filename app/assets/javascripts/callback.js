$(document).ready(function() {
	$('#callback-form').on('ajax:success', function(){
		$('#callback').modal('hide')
		$('#callback-success').modal('show')
	})
})