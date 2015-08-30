// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require bootstrap-sprockets
//= require turbolinks
//= require_tree .
//= require moment
//= require bootstrap-datetimepicker

!function(g,s,q,r,d){r=g[r]=g[r]||function(){(r.q=r.q||[]).push(
arguments)};d=s.createElement(q);q=s.getElementsByTagName(q)[0];
d.src='//d1l6p2sc9645hc.cloudfront.net/tracker.js';q.parentNode.
insertBefore(d,q)}(window,document,'script','_gs');

_gs('GSN-220573-W');

$(function (){
	$('#date').datetimepicker({
		format: 'YYYY/MM/DD H:mm',
		sideBySide: true
	});
});

function updateCountdown() {
    var remaining = 140 - jQuery('.tweet').val().length;
    jQuery('.countdown').text(remaining);
}

jQuery(document).ready(function($) {
    updateCountdown();
    $('.tweet').change(updateCountdown);
    $('.tweet').keyup(updateCountdown);
});