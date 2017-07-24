class UrlParser
  attr_reader :scheme, :domain, :port, :path, :query_string, :fragment_id
  
  def initialize(url)
    @url_remaining = url
    @scheme = parse_url("://")
    post_domain_char = @url_remaining[@url_remaining.index("/")+1]
    if @url_remaining.include?(":")
      @domain = parse_url(":")
      @port = parse_url("/")
    else
      @domain = parse_url("/")
      if @scheme == "http"
        @port = "80"
      elsif @scheme == "https"
        @port = "443"
      end
    end
    remaining_sections = find_remaining_sections(post_domain_char)
    if remaining_sections.include?("path")
      if remaining_sections.include?("query")
        @path = parse_url("?")
      elsif remaining_sections.include?("fragment_id")
        @path = parse_url("\#")
        @fragment_id = @url_remaining
      else
        @path = @url_remaining
        @url_remaining = ''
      end        
    else
      @path = nil
      unless @url_remaining.empty?
        @url_remaining.slice!(0)
      end
    end
    if remaining_sections.include?("query")
      if remaining_sections.include?("fragment_id")
        @query_string = get_query_hash
        @fragment_id = @url_remaining
        @url_remaining = ''
      else
        @query_string = get_query_hash(false)
      end
    end
  end

  def parse_url(parsing_string)
    remaining_segments = @url_remaining.split(parsing_string, 2)
    @url_remaining = remaining_segments[1]
    remaining_segments[0]
  end

  def get_query_hash(fragment_id=true)
    if fragment_id
      queries = parse_url("\#")
    else
      queries = @url_remaining
      @url_remaining = ''
    end
    queries_array = queries.split('&')
    query_hash = Hash.new
    queries_array.each do |query|
      query_array = query.split("=")
      query_hash[query_array[0]] = query_array[1]
    end
    query_hash
  end

  def find_remaining_sections(post_domain_char)
    remaining_sections = []
    if not ["\#", "?"].include?(post_domain_char)
      remaining_sections << "path"
    end
    if @url_remaining.include?("?")
      remaining_sections << "query"
    end
    if @url_remaining.include?("\#")
      remaining_sections << "fragment_id"
    end
    remaining_sections
  end

end