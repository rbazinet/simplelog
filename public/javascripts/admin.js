/** $Id: admin.js 300 2007-02-01 23:01:00Z garrett $ **/

/**
 * Copyright (C) 2006-2007 Garrett Murray
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along
 * with this program (doc/LICENSE); if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301 USA.
 */
 
window.onload = function()
{
    init();
}

// loads tag highlighting if we need it
function init()
{
    // figure out the URL of this site
    figure_url = window.location.href;
    figure_url = figure_url.split('/admin');
    // we've got the URL, move on and keep working
    var simplelog_url = figure_url[0];
    
    loading_img = new Image(); // preload indicator image
    loading_img.src = simplelog_url + '/images/admin/indicator.gif'; // preload
    loading_img_2 = new Image(); // preload indicator image
    loading_img_2.src = simplelog_url + '/images/admin/indicator_dark_bg.gif'; // preload
    arrow_up_img = new Image();
    arrow_up_img.src = simplelog_url + '/images/admin/arrow_up.gif'; // showing
    arrow_down_img = new Image();
    arrow_down_img.src = simplelog_url + '/images/admin/arrow_down.gif'; // showing
    arrow_right_img = new Image();
    arrow_right_img.src = simplelog_url + '/images/admin/arrow_right.gif'; // showing
    green_check_img = new Image();
    green_check_img.src = simplelog_url + '/images/admin/green_check.png';
    light_check_img = new Image();
    light_check_img.src = simplelog_url + '/images/admin/light_check.png';
    el = document.getElementById('tag_input');
    if (el)
    {
        highlight_tags(el);
    }
}

// selects a form field and loads init
function doFieldSelect(command)
{
    init();
    addLoadEvent(command);
}

// adds to the onload stack
function addLoadEvent(func)
{
	var oldonload = window.onload;
	if (typeof window.onload != 'function') {
		window.onload = func;
	} else {
		window.onload = function() {
			oldonload();
			func();
		}
	}
}

/**
 * fun tag behavior, written by garrett murray
 *
 * based on the behavior i've seen at del.icio.us
 * but written from the ground up because their javascript
 * was really complicated and i didn't bother trying to
 * figure it out
 */

// adds or removes a tag
function tag_swap(el, name)
{
    if (!find_tag(el, name))
    {
        var normalized = el.value.replace(/^\s*|\s*$/g,'');
        el.value = (normalized == '' ? '' : normalized + ' ') + name;
        highlight_tags(el);
    }
    else
    // tag already exists, remove it
    {
        tags = el.value.split(' ');
        new_tags = new Array();
        for (var i = 0; i <= tags.length; i++)
        {
            if (tags[i] != name)
            {
                new_tags[new_tags.length] = tags[i];
            }
        }
        el.value = new_tags.join(' ');
        clear_highlight();
        highlight_tags(el);
    }
}

// see if a tag is already in the block
function find_tag(el, name)
{
    tags = el.value.split(' ');
    for (var i = 0; i <= tags.length; i++)
    {
        if (tags[i] == name)
        {
            return true;   
        }
    }
    return false;
}

// highlights tags that are already there
function highlight_tags(el)
{
    tags = el.value.split(' ');
    clear_highlight();
    for (var i = 0; i <= tags.length; i++)
    {
        temp_tag = document.getElementById('tag_' + tags[i]);
        if (temp_tag)
        {
            temp_tag.setAttribute('class', 'tag_tag tag_selected');
        }
    }
}

// clears all highlighted tags
function clear_highlight()
{
    highlighted_tags = getElementsByClass('tag_tag tag_selected');
    for (var x = 0; x < highlighted_tags.length; x++)
    {
        highlighted_tags[x].setAttribute('class', 'tag_tag');
    }
}

// gets an array of all elements with `classname`
function getElementsByClass(classname)
{
    var elements = new Array();
    var inc = 0;
    var alltags = document.all ? document.all : document.getElementsByTagName('*');
    for (var z = 0; z < alltags.length; z++)
    {
        if (alltags[z].className == classname)
        {
            elements[inc++] = alltags[z];
        }
    }
    return elements;
}

/**
 * ping/update display DOM stuff
 */

// doing ping
function pinging(url, bid, id)
{
    document.getElementById(bid).disabled = true;
    document.getElementById(id).innerHTML = '<img src="' + url + '/images/admin/indicator_dark_bg.gif" alt="Working" border="0"/> Pinging...';
}

// ping done
function ping_done(bid, id)
{
    document.getElementById(bid).disabled = false;
    document.getElementById(id).innerHTML = 'Done!';
}

// doing update check
function updating(url, bid, id)
{
    document.getElementById(bid).disabled = true;
    document.getElementById(id).innerHTML = '<img src="' + url + '/images/admin/indicator.gif" alt="Working" border="0"/> Checking...';
}

// update check done
function update_done(bid, id)
{
    document.getElementById(bid).disabled = false;
    document.getElementById(id).innerHTML = 'Done!';
}

/**
 * preview toggle for posting
 */

// show/hide the content preview
function togglePreview(preview_el, note_el)
{
    preview_el = document.getElementById(preview_el);
    note_el = document.getElementById(note_el);
    note_el.style.display = (note_el.style.display == 'none' ? 'block' : 'none');
    preview_el.style.display = (preview_el.style.display == 'none' ? 'block' : 'none');
}

/**
 * check/uncheck the ping box based on post active status
 */
function setPingCheck(f, e, d)
{
    if (f.checked)
    // allow pinging
    {
        e.disabled = false;
        e.checked = (d == 1 ? true : false);
    }
    else
    // post isn't active, we can't allow pinging
    {
        e.checked = false
        e.disabled = true;
    }
}

/**
 * showing the ping panel, help panel, ping functions
 */
function showPingPanel()
{
    showPanel('ping_panel', 'ping_obj', 'ping_status');
    document.forms['ping_form'].elements['pbutton'].focus();
}
function showHelpPanel()
{
    showPanel('help_panel', 'help_obj', '')
}
function showPanel(panel_id, obj_id, status_text_id)
// this is a general-use panel function that creates a centering panel
// depending on the object calling its position
{
    panel = document.getElementById(panel_id);
    if (!panel.style.visibility || panel.style.visibility == 'hidden')
    {
        panel_wd = Math.round(findWidth(panel)/2);
        obj = document.getElementById(obj_id);
        wd = Math.round(findWidth(obj)/2);
        ht = Math.round(findHeight(obj))-2;
        lr = findPosX(obj);
        tb = findPosY(obj);
        panel.style.visibility = 'visible';
        panel.style.top = (tb+ht) + 'px';
        panel.style.left = ((lr+wd)-panel_wd) + 'px';
    }
    else
    {
        panel.style.visibility = 'hidden';
        if (status_text_id != '')
        {
            document.getElementById(status_text_id).innerHTML = 'Awaiting action.';
        }
    }
}
function findWidth(obj)
// return the width of an object
{
    return obj.offsetWidth;
}
function findHeight(obj)
// return the height of an object
{
    return obj.offsetHeight;
}
function findPosX(obj)
// find an object's X position
{
    var curleft = 0;
    if(obj.offsetParent)
    while(1) 
    {
        curleft += obj.offsetLeft;
        if(!obj.offsetParent)
        break;
        obj = obj.offsetParent;
    }
    else if(obj.x)
    curleft += obj.x;
    return curleft;
}
function findPosY(obj)
// find an object's Y position
{
    var curtop = 0;
    if(obj.offsetParent)
    while(1)
    {
        curtop += obj.offsetTop;
        if(!obj.offsetParent)
        break;
        obj = obj.offsetParent;
    }
    else if(obj.y)
    curtop += obj.y;
    return curtop;
}

/**
 * preferences tabs
 */
function swapTab(tab)
{
    ct_field = document.getElementById('current_tab');
    tabs = new Array('site_details', 'display_settings', 'content_settings', 'meta_information', 'advanced_settings');
    for (var t = 0; t < tabs.length; t++)
    {
        tab_obj = document.getElementById('pt_' + tabs[t]);
        link_obj = document.getElementById(tabs[t] + '_l');
        if (tabs[t] == tab)
        {
            setShown(tab_obj);
            ct_field.value = tabs[t];
            link_obj.setAttribute('class', 'pt_current');
        }
        else
        {
            setHidden(tab_obj);
            link_obj.setAttribute('class', '');
        }
    }
}
function setShown(o)
{
    o.style.display = 'block';
}
function setHidden(o)
{
    o.style.display = 'none';
}