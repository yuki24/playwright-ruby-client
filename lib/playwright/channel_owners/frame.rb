module Playwright
  # @ref https://github.com/microsoft/playwright-python/blob/master/playwright/_impl/_frame.py
  define_channel_owner :Frame do
    def after_initialize
      @event_emitter = Object.new.extend(EventEmitter)
      if @initializer['parentFrame']
        @parent_frame = @initializer['parentFrame'].object
        @parent_frame.send(:append_child_frame_from_child, self)
      end
      @name = @initializer['name']
      @url = @initializer['url']
      @detached = false
      @child_frames = Set.new
      @load_states = Set.new(@initializer['loadStates'])
    end

    attr_reader :page

    def goto(url, timeout: nil, waitUntil: nil, referer: nil)
      params = {
        url: url,
        timeout: timeout,
        waitUntil: waitUntil,
        referer: referer
      }.compact
      response = @channel.send_message_to_server('goto', params)
      PlaywrightApi.from_channel_owner(response)
    end

    private

    # @param page [Page]
    # @note This method should be used internally. Accessed via .send method, so keep private!
    def update_page_from_page(page)
      @page = page
    end

    # @param child [Frame]
    # @note This method should be used internally. Accessed via .send method, so keep private!
    def append_child_frame_from_child(frame)
      @child_frames << frame
    end
  end
end
