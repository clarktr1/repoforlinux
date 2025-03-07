
# frozen_string_literal: true

# Blacklight controller that handles searches and document requests
class CatalogController < ApplicationController

    include Blacklight::Catalog
    # include BlacklightRangeLimit::ControllerOverride
  
    include Blacklight::Marc::Catalog
  
    # If you'd like to handle errors returned by Solr in a certain way,
    # you can use Rails rescue_from with a method you define in this controller,
    # uncomment:
    #
    # rescue_from Blacklight::Exceptions::InvalidRequest, with: :my_handling_method
  
    configure_blacklight do |config|
      ## Specify the style of markup to be generated (may be 4 or 5)
      # config.bootstrap_version = 5
      #
      ## Class for sending and receiving requests from a search index
      # config.repository_class = Blacklight::Solr::Repository
      #
      ## Class for converting Blacklight's url parameters to into request parameters for the search index
      # config.search_builder_class = ::SearchBuilder
      #
      ## Model that maps search index responses to the blacklight response model
      # config.response_model = Blacklight::Solr::Response
      #
      ## The destination for the link around the logo in the header
      # config.logo_link = root_path
      #
      ## Should the raw solr document endpoint (e.g. /catalog/:id/raw) be enabled
      # config.raw_endpoint.enabled = false
  
      ## Default parameters to send to solr for all search-like requests. See also SearchBuilder#processed_parameters
      config.default_solr_params = {
        rows: 20,
        'q.op' => 'AND'
      }
  
      # solr path which will be added to solr base url before the other solr params.
      #config.solr_path = 'select'
      #config.document_solr_path = 'get'
      #config.json_solr_path = 'advanced'
  
      # items to show per page, each number in the array represent another option to choose from.
      #config.per_page = [10,20,50,100]
  
      # solr field configuration for search results/index views
      config.index.title_field = 'display_title'
      # config.index.display_type_field = 'format'
      # config.index.thumbnail_field = 'thumbnail_path_ss'
  
      # The presenter is the view-model class for the page
      # config.index.document_presenter_class = MyApp::IndexPresenter
  
      # Some components can be configured
      # config.index.document_component = MyApp::SearchResultComponent
      # config.index.constraints_component = MyApp::ConstraintsComponent
      # config.index.search_bar_component = MyApp::SearchBarComponent
      # config.index.search_header_component = MyApp::SearchHeaderComponent
      # config.index.document_actions.delete(:bookmark)
  
      config.add_results_document_tool(:bookmark, component: Blacklight::Document::BookmarkComponent, if: :render_bookmarks_control?)
  
      config.add_results_collection_tool(:sort_widget)
      config.add_results_collection_tool(:per_page_widget)
      config.add_results_collection_tool(:view_type_group)
  
      config.add_show_tools_partial(:bookmark, component: Blacklight::Document::BookmarkComponent, if: :render_bookmarks_control?)
      # config.add_show_tools_partial(:email, callback: :email_action, validator: :validate_email_params)
      # config.add_show_tools_partial(:sms, if: :render_sms_action?, callback: :sms_action, validator: :validate_sms_params)
      config.add_show_tools_partial(:citation)
  
      config.add_nav_action(:bookmark, partial: 'blacklight/nav/bookmark', if: :render_bookmarks_control?)
      config.add_nav_action(:search_history, partial: 'blacklight/nav/search_history')
  
      # solr field configuration for document/show views config.show.title_field = 'title_tsim'
      # config.show.display_type_field = 'format' config.show.thumbnail_field = 'thumbnail_path_ss'
      #
      # The presenter is a view-model class for the page config.show.document_presenter_class = MyApp::ShowPresenter
      #
      # These components can be configured config.show.document_component = MyApp::DocumentComponent
      # config.show.sidebar_component = MyApp::SidebarComponent config.show.embed_component = MyApp::EmbedComponent
  
      # solr fields that will be treated as facets by the blacklight application The ordering of the field names is
      #   the order of the display
      #
      # Setting a limit will trigger Blacklight's 'more' facet values link. * If left unset, then all facet values
      # returned by solr will be displayed. * If set to an integer, then "f.somefield.facet.limit" will be added to
      # solr request, with actual solr request being +1 your configured limit -- you configure the number of items
      # you actually want _displayed_ in a page. * If set to 'true', then no additional parameters will be sent to
      # solr, but any 'sniffed' request limit parameters will be used for paging, with paging at requested limit -1.
      # Can sniff from facet.limit or f.specific_field.facet.limit solr request params. This 'true' config can be
      # used if you set limits in :default_solr_params, or as defaults on the solr side in the request handler
      # itself. Request handler defaults sniffing requires solr requests to be made with "echoParams=all", for app
      # code to actually have it echo'd back to see it.
      #
      # :show may be set to false if you don't want the facet to be drawn in the
      # facet bar
      #
      # set :index_range to true if you want the facet pagination view to have facet prefix-based navigation
      #  (useful when user clicks "more" on a large facet and wants to navigate alphabetically across a large set of results)
      # :index_range can be an array or range of prefixes that will be used to create the navigation (note: It is case sensitive when searching values)
  
      # config.add_facet_field 'author_place', label: 'Location'
  
      config.add_facet_field 'str_author', label: 'Author', limit: 10, index_range: true
      config.add_facet_field 'str_publisher', label: 'Publisher', limit:10, index_range: true
  
      config.add_facet_field 'publish_date_sort', label: 'Publish Year Decade', :query => {
        :decade_1890s => { label: '1890 - 1899', fq: "publish_date_sort:[1890 TO 1899]" },
        :decade_1900s => { label: '1900 - 1909', fq: "publish_date_sort:[1900 TO 1909]" },
        :decade_1910s => { label: '1910 - 1919', fq: "publish_date_sort:[1910 TO 1919]" },
        :decade_1920s => { label: '1920 - 1929', fq: "publish_date_sort:[1920 TO 1929]" },
        :decade_1930s => { label: '1930 - 1939', fq: "publish_date_sort:[1930 TO 1939]" },
        :decade_1940s => { label: '1940 - 1949', fq: "publish_date_sort:[1940 TO 1949]" },
        :decade_1950s => { label: '1950 - 1959', fq: "publish_date_sort:[1950 TO 1959]" },
        :decade_1960s => { label: '1960 - 1969', fq: "publish_date_sort:[1960 TO 1969]" },
        :decade_1970s => { label: '1970 - 1979', fq: "publish_date_sort:[1970 TO 1979]" },
        :decade_1980s => { label: '1980 - 1989', fq: "publish_date_sort:[1980 TO 1989]" },
      }
  
      config.add_facet_field 'catalog_issue_date_sort', label: 'Catalog Issue Year Decade', :query => {
        :decade_1890s => { label: '1890 - 1899', fq: "catalog_issue_date_sort:[1890 TO 1899]" },
        :decade_1900s => { label: '1900 - 1909', fq: "catalog_issue_date_sort:[1900 TO 1909]" },
        :decade_1910s => { label: '1910 - 1919', fq: "catalog_issue_date_sort:[1910 TO 1919]" },
        :decade_1920s => { label: '1920 - 1929', fq: "catalog_issue_date_sort:[1920 TO 1929]" },
        :decade_1930s => { label: '1930 - 1939', fq: "catalog_issue_date_sort:[1930 TO 1939]" },
        :decade_1940s => { label: '1940 - 1949', fq: "catalog_issue_date_sort:[1940 TO 1949]" },
        :decade_1950s => { label: '1950 - 1959', fq: "catalog_issue_date_sort:[1950 TO 1959]" },
        :decade_1960s => { label: '1960 - 1969', fq: "catalog_issue_date_sort:[1960 TO 1969]" },
        :decade_1970s => { label: '1970 - 1979', fq: "catalog_issue_date_sort:[1970 TO 1979]" }
      }
  
      config.add_facet_field 'sudocStem', label: 'Sudoc Stem', limit: 10, index_range: true
  
      config.add_facet_field 'publish_year', label: 'Publish Year', collapse: false, range: true, range_config: {
             chart_js: false,
             textual_facets: false
      }
      config.add_facet_field 'catalog_issue_year', label: 'Catalog Issue Year', collapse: false, range: true, range_config: {
             chart_js: false,
             textual_facets: false
      }
  
      # Have BL send all facet field names to Solr, which has been the default
      # previously. Simply remove these lines if you'd rather use Solr request
      # handler defaults, or have no facets.
      config.add_facet_fields_to_solr_request!
  
      # solr fields to be displayed in the index (search results) view
      #   The ordering of the field names is the order of the display
      config.add_index_field 'corporate_agency_authors', label: 'Corporate/Agency Authors'
      config.add_index_field 'publish_author', label: 'Publisher'
      config.add_index_field 'display_date', label: 'Date'
      config.add_index_field 'sudoc_display', label: 'SuDoc number'
  
      # solr fields to be displayed in the show (single result) view
      #   The ordering of the field names is the order of the display
      config.add_show_field 'publish_title', label: 'Publication Title'
      config.add_show_field 'display_title', label: 'Display Title'
      config.add_show_field 'appendix_title', label: 'Appendix Title'
      config.add_show_field 'series_title', label: 'Series Title'
      config.add_show_field 'corporate_agency_authors', label: 'Corporate Agency Authors'
      config.add_show_field 'sortauth', label: 'Sort Author'
      config.add_show_field 'personal_authors', label: 'Authors'
      config.add_show_field 'series_personal_authors', label: 'Series Personal Authors'
      config.add_show_field 'author_place', label: 'Author place'
      config.add_show_field 'author_zip', label: 'Author zip'
      config.add_show_field 'display_date', label: 'Date'
      config.add_show_field 'publish_date_sort', label: 'Publish Date ISO Format'
      config.add_show_field 'publish_date_start', label: 'Publication Start'
      config.add_show_field 'publish_date_end', label: 'Publication End'
      #config.add_show_field 'publish_sortdate', label: 'Publication Date Sort'
      config.add_show_field 'publish_author', label: 'Corporate/Agency Author'
      config.add_show_field 'publish_month', label: 'Publication month'
      config.add_show_field 'publish_year', label: 'Publication year'
      config.add_show_field 'publish_date', label: 'Publication date'
      config.add_show_field 'publish_place', label: 'Publication place'
      config.add_show_field 'publish_frequency', label: 'Publication frequency'
      config.add_show_field 'printer', label: 'Printer'
      config.add_show_field 'sudoc_display', label: 'SuDoc number'
      config.add_show_field 'su_corrected_in', label: 'SuDoc correction date'
      config.add_show_field 'su_correction_imported', label: 'SuDoc correction'
      config.add_show_field 'description', label: 'Description'
      config.add_show_field 'notes', label: 'Notes'
      config.add_show_field 'snotes', label: 'Notes'
      config.add_show_field 'explanatory_note', label: 'Notes'
      config.add_show_field 'availability', label: 'Availability'
      config.add_show_field 'gpo_item_num', label: 'GPO Item number'
      config.add_show_field 'stock_no', label: 'Stock number'
      config.add_show_field 'catalog_issue_date', label: 'Monthly Catalog date'
      config.add_show_field 'catalog_issue_num', label: 'Monthly Catalog issue number'
      config.add_show_field 'catalog_page_num', label: 'Monthly Catalog page number'
      config.add_show_field 'catalog_issue_date_sort', label: 'Monthly Catalog issue date'
      config.add_show_field 'rec_no', label: 'Monthly Catalog entry number'
      # config.add_show_field 'zone_info', label: 'Record coordinates'
      config.add_show_field 'lcnum', label: 'LC Number'
      config.add_show_field 'contract_num', label: 'Contract Number'
      config.add_show_field 'startpage', label: 'Record start page number'
      config.add_show_field 'end', label: 'Record end page number'
  
      # "fielded" search configuration. Used by pulldown among other places.
      # For supported keys in hash, see rdoc for Blacklight::SearchFields
      #
      # Search fields will inherit the :qt solr request handler from
      # config[:default_solr_parameters], OR can specify a different one
      # with a :qt key/value. Below examples inherit, except for subject
      # that specifies the same :qt as default for our own internal
      # testing purposes.
      #
      # The :key is what will be used to identify this BL search field internally,
      # as well as in URLs -- so changing it after deployment may break bookmarked
      # urls.  A display label will be automatically calculated from the :key,
      # or can be specified manually to be different.
  
      # This one uses all the defaults set by the solr request handler. Which
      # solr request handler? The one set in config[:default_solr_parameters][:qt],
      # since we aren't specifying it otherwise.
  
      # config.add_search_field 'all_field', label: 'All Fields'
  
      config.add_search_field('all_fields') do |field|
        field.solr_parameters = {
          qf: '${all_qf}',
          pf: '${all_pf}'
        }
      end
      # Now we see how to over-ride Solr request handler defaults, in this
      # case for a BL "search field", which is really a dismax aggregate
      # of Solr search fields.
  
      config.add_search_field('title') do |field|
        # solr_parameters hash are sent to Solr as ordinary url query params.
        field.solr_parameters = {
          qf: 'display_title^10',
          pf: 'display_title^20'
        }
      end
  
      config.add_search_field('publisher') do |field|
        # solr_parameters hash are sent to Solr as ordinary url query params.
        field.solr_parameters = {
          qf: 'publish_author^10',
          pf: 'publish_author^20'
        }
      end
  
      config.add_search_field('author') do |field|
        field.solr_parameters = {
          'spellcheck.dictionary': 'author',
          qf: '${authors_qf}',
          pf: '${authors_pf}'
        }
      end
  
      config.add_search_field('Publication Year') do |field|
        field.solr_parameters = {
          qf: 'str_pub_year^10',
          pf: 'str_pub_year^20'
        }
      end
  
     config.add_search_field('Issue Year') do |field|
        field.solr_parameters = {
          qf: 'str_issue_year^10',
          pf: 'str_issue_year^20'
        }
      end
  
      config.add_search_field('Full SuDoc') do |field|
        field.solr_parameters = {
          qf: 'sudocs^10',
          pf: 'sudocs^20'
        }
      end
  
      config.add_search_field('LC Number') do |field|
        field.solr_parameters = {
          qf: 'lcnum^10',
          pf: 'lcnum^20'
        }
      end
  
      # Specifying a :qt only to show it's possible, and so our internal automated
      # tests can test it. In this case it's the same as
      # config[:default_solr_parmeters][:qt], so isn't actually neccesary.
  
  
      # "sort results by" select (pulldown)
      # label in pulldown is followed by the name of the Solr field to sort by and
      # whether the sort is ascending or descending (it must be asc or desc
      # except in the relevancy case). Add the sort: option to configure a
      # custom Blacklight url parameter value separate from the Solr sort fields.
  
      config.add_sort_field 'newest', sort: 'publish_date_sort desc, str_display_title asc', label: 'Newest First'
      config.add_sort_field 'oldest', sort: 'publish_date_sort asc, str_display_title asc', label: 'Oldest First'
      config.add_sort_field 'title_asc', sort: 'str_display_title asc', label: 'Title A-Z'
      config.add_sort_field 'title_desc', sort: 'str_display_title desc', label: 'Title Z-A'
      config.add_sort_field 'relevance', sort: 'score desc, publish_date_sort desc, str_display_title asc', label: 'Relevance'
  
      # If there are more than this many search results, no spelling ("did you
      # mean") suggestion is offered.
      config.spell_max = 5
  
      # Configuration for autocomplete suggester
      config.autocomplete_enabled = true
      config.autocomplete_path = 'suggest'
      # if the name of the solr.SuggestComponent provided in your solrconfig.xml is not the
      # default 'mySuggester', uncomment and provide it below
      # config.autocomplete_suggester = 'mySuggester'
    end
  end