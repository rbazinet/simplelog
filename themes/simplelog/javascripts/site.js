/** $Id: site.js 275 2007-01-11 21:06:20Z garrett $ **/

/**
 * simplelog site functions
 * hides appropriate divs on launch, shows divs, etc, etc
 * search box functionality as well
 */
 
window.onload = function()
{
	init(); // see below, this is to get around global vars not being ready
}
function init()
// init vars, run some initial functions
{
	body_container = document.getElementById('wrapper');
	search_field = document.getElementById('q');
	search_div = document.getElementById('search');
	results_wrapper_div = document.getElementById('search_results');
	loading_msg_span = document.getElementById('loading');
	results_span = document.getElementById('results');
	tag_block = document.getElementById('tags');
	author_block = document.getElementById('authors');

	default_field_value = 'Enter your terms, hit enter';
	message_when_searching = 'Searching...';
	message_when_done = '';
	results_when_searching = '';

	passive_search_text_color = '#777';
	active_search_text_color = '#000';

	isIE = false;

	searchInit(search_field); // capture key events
	clearSearch(); // set everything right with search field / areas
}
function showResults(bool)
{
	results_wrapper_div.style.display = 'inline';
	if (!bool)
	{
		loading_msg_span.innerHTML = message_when_searching;
		results_span.innerHTML = results_when_searching;
		results_span.style.display = 'inline';
	}
	else
	{
		loading_msg_span.innerHTML = message_when_done;
		results_span.style.display = 'block'; // for some reason, you have to go to block then back
		results_span.style.display = 'inline'; // to avoid it from dropping down a line in ff
	}
}
function searchInit()
{
	if (navigator.userAgent.indexOf('Safari') > 0)
	{
		search_field.addEventListener('keydown',searchKeyPress,false);
	}
	else if (navigator.product == 'Gecko')
	{
		search_field.addEventListener('keypress',searchKeyPress,false);
	}
	else
	{
		search_field.attachEvent('onkeydown',searchKeyPress);
		search_field.blur();
		isIE = true;
	}
}
function searchKeyPress(event)
{
	if (event.keyCode == 27)
	// escape key pressed
	{
		clearSearch();
	}
}
function clearSearch()
// clears the search field, sets its default color and value, hides appropriate areas
{
	search_div.style.display = 'none';
	search_field.style.color = passive_search_text_color;
	search_field.value = default_field_value;
	results_wrapper_div.style.display = 'none';
}
function searchFocus()
{
	search_field.style.color = active_search_text_color;
	if (search_field.value == default_field_value)
	{
		search_field.value = '';
	}
}
function showSearch()
{
	if (search_div.style.display == 'block')
	{
		clearSearch();
	}
	else
	{
		search_div.style.display = 'block';
	}
}
function showTags()
{
	if (tag_block.style.display == 'block')
	{
		tag_block.style.display = 'none';
	}
	else
	{
		tag_block.style.display = 'block';
	}
}
function showAuthors()
{
	if (author_block.style.display == 'block')
	{
		author_block.style.display = 'none';
	}
	else
	{
		author_block.style.display = 'block';
	}
}