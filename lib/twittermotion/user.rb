module Twitter
  class User
    attr_accessor :ac_account

    def initialize(ac_account)
      self.ac_account = ac_account
    end

    def username
      self.ac_account.username
    end

    def user_id
      self.ac_account.valueForKeyPath("properties")["user_id"]
    end

    # user.compose(tweet: 'initial tweet', images: [ui_image, ui_image],
    #   urls: ["http://", ns_url, ...]) do |composer|
    #
    # end
    def compose(options = {}, &block)
      @composer = Twitter::Composer.new
      @composer.compose(options) do |composer|
        block.call(composer)
      end
    end

    # user.get_timeline(include_entities: 1) do |hash, ns_error|
    # end

    [[:timeline, "http://api.twitter.com/1.1/statuses/home_timeline.json"],
     [:friends, "http://api.twitter.com/1.1/friends/ids.json"],
     [:followers, "http://api.twitter.com/1.1/followers/ids.json"]].each do |type, url|
      define_method("get_#{type}") do |options = {}, &block|
        get(url, options) do |response_data, url_response, error|
          if !response_data
            block.call(nil, error)
          else
            block.call(BubbleWrap::JSON.parse(response_data), nil)
          end
        end
      end
    end

    private

    def get(url, options = {}, &block)
      request = TWRequest.alloc.initWithURL(NSURL.URLWithString(url),
                                            parameters:options,
                                            requestMethod:TWRequestMethodGET)
      request.account = self.ac_account
      request.performRequestWithHandler(block)
    end
  end
end
