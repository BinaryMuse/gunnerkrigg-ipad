fs      = require 'fs'
express = require 'express'
jsdom   = require 'jsdom'
jQuery  = fs.readFileSync "#{__dirname}/public/jQuery-1.7.2.js", 'utf8'

baseUrl = "http://www.gunnerkrigg.com"

comicUrl = (num) ->
  str = '' + num
  while str.length < 8
    str = '0' + str
  "http://www.gunnerkrigg.com/comics/#{str}.jpg"

getCurrentComicId = (path, callback) ->
  jsdom.env
    html: "#{baseUrl}#{path}"
    src: [jQuery]
    done: (errors, window) =>
      $ = window.jQuery
      image = $('.rss-id img').attr('src')
      matches = image.match /(\d+).jpg$/
      callback parseInt(matches[1], 10)

app = express.createServer()

app.configure ->
  app.set 'views', "#{__dirname}/views"
  app.set 'view engine', 'jade'
  app.use express.static("#{__dirname}/public")

app.get '/', (req, res) ->
  getCurrentComicId '/index2.php', (id) =>
    res.redirect "/#{id}"

app.get '/:id', (req, res) ->
  current = parseInt req.params.id, 10
  getCurrentComicId '/index2.php', (id) =>
    prevId = if current == 1 then id else current - 1
    nextId = if current == id then 1 else current + 1
    res.render 'index'
      comic:
        latestId: id
        prevImage: comicUrl(prevId)
        image: comicUrl(current)
        nextImage: comicUrl(nextId)
        prevId: prevId
        id: current
        nextId: nextId

app.listen process.env.PORT ? 3000
