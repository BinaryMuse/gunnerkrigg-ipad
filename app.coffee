fs      = require 'fs'
express = require 'express'
restler = require 'restler'
jsdom   = require 'jsdom'
jQuery  = fs.readFileSync "#{__dirname}/public/jQuery-1.7.2.js", 'utf8'

baseUrl = "http://www.gunnerkrigg.com"
getComic = (path, callback) ->
  jsdom.env
    html: "#{baseUrl}#{path}"
    src: [jQuery]
    done: (errors, window) =>
      $ = window.jQuery
      prevLink = $('img[src="images/prev_a.jpg"]').parents('a').first().attr('href') ? ''
      nextLink = $('img[src="images/next_a.jpg"]').parents('a').first().attr('href') ? ''
      if matches = prevLink.match /comicID=(\d+)/
        prevId = matches[1]
      if matches = nextLink.match /comicID=(\d+)/
        nextId = matches[1]
      image = $('.rss-id img').attr('src')
      callback image, prevId, nextId

app = express.createServer()

app.configure ->
  app.set 'views', "#{__dirname}/views"
  app.set 'view engine', 'jade'
  app.use express.static("#{__dirname}/public")

app.get '/', (req, res, next) ->
  getComic '/index2.php', (image, prevId, nextId) =>
    req.gkc =
      image: image
      prevId: prevId
      nextId: nextId
    next()

app.get '/:id', (req, res, next) ->
  getComic "/archive_page.php?comicID=#{req.params.id}", (image, prevId, nextId) =>
    req.gkc =
      image: image
      prevId: prevId
      nextId: nextId
    next()

app.get '*', (req, res) ->
  if req.gkc.image?
    res.render 'index'
      comic: req.gkc
  else
    res.render 'error'

app.listen 3000
