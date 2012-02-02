module Kaminari
  # = Helpers
  module ActionViewExtension
    # A helper that renders the pagination links.
    #
    #   <%= paginate @articles %>
    #
    # ==== Options
    # * <tt>:window</tt> - The "inner window" size (4 by default).
    # * <tt>:outer_window</tt> - The "outer window" size (0 by default).
    # * <tt>:left</tt> - The "left outer window" size (0 by default).
    # * <tt>:right</tt> - The "right outer window" size (0 by default).
    # * <tt>:params</tt> - url_for parameters for the links (:controller, :action, etc.)
    # * <tt>:param_name</tt> - parameter name for page number in the links (:page by default)
    # * <tt>:remote</tt> - Ajax? (false by default)
    # * <tt>:ANY_OTHER_VALUES</tt> - Any other hash key & values would be directly passed into each tag as :locals value.
    def paginate(scope, options = {}, &block)
      paginator = Kaminari::Helpers::Paginator.new self, options.reverse_merge(:current_page => scope.current_page, :num_pages => scope.num_pages, :per_page => scope.limit_value, :param_name => Kaminari.config.param_name, :remote => false)
      paginator.to_s
    end

    # A simple "Twitter like" pagination link that creates a link to the next page.
    #
    # ==== Examples
    # Basic usage:
    #
    #   <%= link_to_next_page @items, 'Next Page' %>
    #
    # Ajax:
    #
    #   <%= link_to_next_page @items, 'Next Page', :remote => true %>
    #
    # By default, it renders nothing if there are no more results on the next page.
    # You can customize this output by passing a block.
    #
    #   <%= link_to_next_page @users, 'Next Page' do %>
    #     <span>No More Pages</span>
    #   <% end %>
    def link_to_next_page(scope, name, options = {}, &block)
      params = options.delete(:params) || {}
      param_name = options.delete(:param_name) || Kaminari.config.param_name
      link_to_unless scope.last_page?, name, params.merge(param_name => (scope.current_page + 1)), options.reverse_merge(:rel => 'next') do
        block.call if block
      end
    end

    # Renders a helpful message with numbers of displayed vs. total entries.
    # Ported from mislav/will_paginate
    #
    # ==== Examples
    # Basic usage:
    #
    #   <%= page_entries_info @posts %>
    #   #-> Displaying posts 6 - 10 of 26 in total
    #
    # By default, the message will use the humanized class name of objects
    # in collection: for instance, "project types" for ProjectType models.
    # Override this with the <tt>:entry_name</tt> parameter:
    #
    #   <%= page_entries_info @posts, :entry_name => 'item' %>
    #   #-> Displaying items 6 - 10 of 26 in total
    def page_entries_info(collection, options = {})
      entry_name = options[:entry_name] || (collection.empty?? 'entry' : collection.first.class.name.underscore.sub('_', ' '))
      output = ""
      if collection.num_pages < 2
        output = case collection.total_count
        when 0; "No #{entry_name.pluralize} found"
        when 1; "Displaying <b>1</b> #{entry_name}"
        else;   "Displaying <b>all #{collection.total_count}</b> #{entry_name.pluralize}"
        end
      else
        offset = (collection.current_page - 1) * collection.limit_value
        output = %{Displaying #{entry_name.pluralize} <b>%d&nbsp;-&nbsp;%d</b> of <b>%d</b> in total} % [
          offset + 1,
          offset + collection.current_page_count,
          collection.total_count
        ]
      end
      output.html_safe
    end

    # Renders rel="next" and rel="prev" links to be used in the head.
    #
    # ==== Examples
    # Basic usage:
    #
    #   In head:
    #   <head>
    #     <title>My Website</title>
    #     <%= yield :head %>
    #   </head>
    #
    #   Somewhere in body:
    #   <% content_for :head do %>
    #     <%= rel_next_prev_link_tags @items %>
    #   <% end %>
    #
    #   #-> <link rel="next" href="/items/page/3" /><link rel="prev" href="/items/page/1" />
    #
    def rel_next_prev_link_tags(scope, options = {})
      params = options.delete(:params) || {}
      param_name = options.delete(:param_name) || Kaminari.config.param_name

      output = ""

      if !scope.first_page? && !scope.last_page?
        # If not first and not last, then output both links.
        output << '<link rel="next" href="' + url_for(params.merge(param_name => (scope.current_page + 1))) + '"/>'
        output << '<link rel="prev" href="' + url_for(params.merge(param_name => (scope.current_page - 1))) + '"/>'
      elsif scope.first_page?
        # If first page, add next link unless last page.
        output << '<link rel="next" href="' + url_for(params.merge(param_name => (scope.current_page + 1))) + '"/>' unless scope.last_page?
      else
        # If last page, add prev link unless first page.
        output << '<link rel="prev" href="' + url_for(params.merge(param_name => (scope.current_page - 1))) + '"/>' unless scope.first_page?
      end

      output.html_safe
    end

  end
end
