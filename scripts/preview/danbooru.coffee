{BasicScraper} = require 'preview'
preferences = require 'preferences'
Uri = require 'uri'

exports = class DanbooruScraper extends BasicScraper
  @getSites: ->
    for site in preferences.get('danbooruSites').split(/\s+/) when site isnt ''
      site = "http://#{site}" unless ///^ http:// ///.test(site)
      new Uri site
  
  @doesUriMatch: (uri) ->
    for booru in this.getSites()
      if uri.isInDomain booru.host
        return uri.globPath('/post/show/**')
    false
  
  scrape: ->
    if id = @uri.path.match(/// ^/post/show/ (\d+) /? ///)?[1]
      
      # need a better way to do this since it has already been looked up once
      for booru in DanbooruScraper.getSites()
        break if @uri.isInDomain booru.host
      
      this.ajax "#{booru}/post/index.json", tags: "id:#{id}", limit: 1, ([post]) =>
        this.createPreview
          title: "#{booru.host} post ##{post.id}"
          thumbnail: "#{booru}#{post.preview_url}"
          dimensions: [post.height, post.width]
          size: post.file_size
          score: post.score
          timestamp: new Date(post.created_at.s)
          author: {name: post.author, uri: "#{booru}/user/show/#{post.creator_id}"}
          source: {name: post.source?.replace(///^ \w+ :// ///, ''), uri: post.source}
    else
      this.pass()
