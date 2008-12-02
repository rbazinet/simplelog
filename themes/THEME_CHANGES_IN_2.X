Theme changes from 1.x to 2.x
--------------------------------------------

The structure for themes has changed significantly from version 1.x of
SimpleLog to version 2.x. For the most part, themes should be auto-
matically updated when running the upgrade rake task, but you may need
to make minor modifications to clean things up.


Name Changes
============

Here is a list of all the original default template files and their new
names/locations. For this example, we're using the "default" theme,
which was included with 1.x and the "simplelog" theme, which is its
replacement and was included with 2.x.

"default" theme (1.x structure) and the changed names

layouts/
    post.rhtml                          (=> site.rhtml)
views/
    page/
        show.rhtml                      (=> pages/show.rhtml)
    post/
        _bottom_nav.rhtml               (=> includes/_footer.rhtml)
        _post_item.rhtml                (=> posts/_item.rhtml and posts/_item_detailed.rhtml)
        _sidebar.rhtml                  (=> includes/_sidebar.rhtml)
        archives_list.rhtml             (=> archives/list.rhtml)
        by_author.rhtml                 (=> archives/by_author.rhtml)
        by_day.rhtml                    (=> archives/daily.rhtml)
        by_month.rhtml                  (=> archives/monthly.rhtml)
        by_year.rhtml                   (=> archives/yearly.rhtml)
        feed_all_rss.rxml               (=> feeds/posts.rxml)
        feed_comments_rss.rxml          (=> feeds/comments.rxml)
        handle_unknown_request.rhtml    (=> errors/unknown_request.rhtml)
        list.rhtml                      (=> index.rhtml)
        search.rhtml                    (=> search/results.rhtml and search/full_results.rhtml)
        show.rhtml                      (=> posts/show.rhtml)
        tagged.rhtml                    (=> archives/by_tag.rhtml)
        tags_list.rhtml                 (=> archives/list_tags.rhtml)
            

"simplelog" theme (2.x structure) with new names and locations

layouts/
    site.rhtml
views/
    index.rhtml
    archives/
        by_author.rhtml
        by_tag.rhtml
        daily.rhtml
        list.rhtml
        list_tags.rhtml
        monthly.rhtml
        yearly.rhtml
    errors/
        unknown_request.rhtml
    feeds/
        comments.rxml
        posts.rxml
    includes/
        _browser_check.rhtml
        _footer.rhtml
        _sidebar.rhtml
    pages/
        show.rhtml
    posts/
        _item.rhtml
        _item_detailed.rhtml
        show.rhtml
    search/
        full_results.rhtml
        results.rhtml


Old Assumptions
===============

Your themes should not rely on common SimpleLog javascripts (such as
prototype) or common images residing in the public/images directory,
since SimpleLog could be updated and changed at any time and you wouldn't
want that to affect your themes.

If you want to use Prototype or other default javascript files, copy them
into the appropriate location in your themes, this way your theme is
safe in the future.
