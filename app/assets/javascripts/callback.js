$(document).ready(function() {
	$('#callback-form').on('ajax:success', function(event, xhr, settings){
		if (xhr == 'OK'){
			$('#callback').modal('hide')
			$('#callback-success').modal('show')
		} else{
			alert(xhr)
		}
	})
})