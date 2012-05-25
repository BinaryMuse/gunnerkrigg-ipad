jQuery(function() {
  var left = $('.images .left');
  var center = $('.images .current');
  var right = $('.images .right');
  var latestId = $('.images').data('latest-comic-id');

  var comicUrl = function(num) {
    var str = '' + num;
    while (str.length < 8) {
      str = '0' + str;
    }
    return "http://www.gunnerkrigg.com/comics/" + str + ".jpg"
  };

  var swipeStatus = function(event, phase, direction, distance) {
    if (phase == 'move') {
      if (direction == 'left') {
        var amount = -1 * distance;
        moveComics(amount, 0);
      } else if (direction == 'right') {
        var amount = distance;
        moveComics(amount, 0);
      }
    } else if (phase == 'cancel') {
      moveComics(0, 1000);
    } else if (phase == 'end') {
      if (direction == 'left') {
        moveComics(-600, 500, function() {
          resetComics('right');
        });
      } else if (direction == 'right') {
        moveComics(600, 500, function() {
          resetComics('left');
        });
      }
    }
  };

  var resetComics = function(which) {
    var img = $('.images .' + which + ' img');
    var src = img.attr('src');
    var id = parseInt(img.data('comic-id'), 10);
    history.pushState({}, '', '/' + id);

    var prevId = id == 1 ? latestId : id - 1;
    var nextId = id == latestId ? 1 : id + 1;

    $('.images .current img').attr('src', src);
    $('.images .current img').data('comic-id', id);
    $('.images .left img').attr('src', comicUrl(prevId));
    $('.images .left img').data('comic-id', prevId);
    $('.images .right img').attr('src', comicUrl(nextId));
    $('.images .right img').data('comic-id', nextId);

    moveComics(0, 0);
  };

  $('body').swipe({
    triggerOnTouchEnd: true,
    swipeStatus: swipeStatus,
    allowPageScroll: 'none',
    threshold: 100,
    timeThreshold: 10 * 1000
  });

  var moveComics = function(pos, duration, callback) {
    var time = (duration/1000).toFixed(1)
    $('img').css('-webkit-transition-duration', time + 's');
    $('img').css('-webkit-transform', 'translate3d(' + pos + 'px,0px,0px)');
    if (callback) {
      callback();
    }
  };
});
