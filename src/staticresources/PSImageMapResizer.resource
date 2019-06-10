/*! Image Map Resizer
 *  Desc: Resize HTML imageMap to scaled image.
 *  Copyright: (c) 2014-15 David J. Bradshaw - dave@bradshaw.net
 *  License: MIT
 */

;(function() {
  'use strict'

  var comp;
  
  function scaleImageMap() {
  console.log('scaleImageMap...');
    function resizeMap() {
      function resizeAreaTag(cachedAreaCoords, idx) {
        function scale(coord) {
          var dimension = 1 === (isWidth = 1 - isWidth) ? 'width' : 'height'
          return (
            padding[dimension] +
            Math.floor(Number(coord) * scalingFactor[dimension])
          )
        }

        var isWidth = 0
        areas[idx].coords = cachedAreaCoords
          .split(',')
          .map(scale)
          .join(',')
      }

      var scalingFactor = {
        width: image.width / image.naturalWidth,
        height: image.height / image.naturalHeight,
      }

      var padding = {
        width: parseInt(
          window.getComputedStyle(image, null).getPropertyValue('padding-left'),
          10
        ),
        height: parseInt(
          window.getComputedStyle(image, null).getPropertyValue('padding-top'),
          10
        ),
      }

      cachedAreaCoordsArray.forEach(resizeAreaTag)
    }

    function getCoords(e) {
      //Normalize coord-string to csv format without any space chars
      return e.coords.replace(/ *, */g, ',').replace(/ +/g, ',')
    }

    function debounce() {
      clearTimeout(timer)
      timer = setTimeout(resizeMap, 250)
    }

    function start() {
      if (
        image.width !== image.naturalWidth ||
        image.height !== image.naturalHeight
      ) {
        resizeMap()
      }
    }

    function addEventListeners() {
    console.log('adding event listeners...');
      image.addEventListener('load', resizeMap, false) //Detect late image loads in IE11
      window.addEventListener('focus', resizeMap, false) //Cope with window being resized whilst on another tab
      window.addEventListener('resize', debounce, false)
      window.addEventListener('readystatechange', resizeMap, false)
      document.addEventListener('fullscreenchange', resizeMap, false)
    }

    function beenHere() {
      return 'function' === typeof map._resize
    }

    function getImg(name) {
      return comp.template.querySelector('img[usemap="' + name + '"]')
    }

    function setup() {
     console.log('setup...');
      areas = map.getElementsByTagName('area')
console.log('areas=' + JSON.stringify(areas));
      cachedAreaCoordsArray = Array.prototype.map.call(areas, getCoords)
console.log('cachedAreaCoordsArray=' + JSON.stringify(cachedAreaCoordsArray));
console.log('map.name=' + map.name);
      image = getImg('#' + map.name) || getImg(map.name)
console.log('image=' + JSON.stringify(image));
      map._resize = resizeMap //Bind resize method to HTML map element
    }

    var /*jshint validthis:true */
      map = this,
      areas = null,
      cachedAreaCoordsArray = null,
      image = null,
      timer = null

    if (!beenHere()) {
      setup()
      addEventListeners()
      start()
    } else {
      map._resize() //Already setup, so just resize map
    }
  }

  function factory() {
  console.log('factory called...');
    function chkMap(element) {
    console.log('chkMap...');
    console.log('tagName=' + element.tagName);
      if (!element.tagName) {
        throw new TypeError('Object is not a valid DOM element')
      } else if ('MAP' !== element.tagName.toUpperCase()) {
        throw new TypeError(
          'Expected <MAP> tag, found <' + element.tagName + '>.'
        )
      }
    }

    function init(element) {
    console.log('init...');
      if (element) {
        chkMap(element)
        scaleImageMap.call(element)
        maps.push(element)
      }
    }

    var maps;
    
    console.log('A...');

    return function imageMapResizeF(target, c) {
      maps = [] // Only return maps from this call
      comp = c;
      console.log('imageMapResizeF...');

      switch (typeof target) {
        case 'undefined':
        case 'string':
          console.log('AA...');
          var matches = document.querySelectorAll('map');
          console.log(JSON.stringify(matches));
          
          Array.prototype.forEach.call(
            document.querySelectorAll(target || 'map'),
            init
          )
          break
        case 'object':
        console.log('BB...');
          init(target);
          break
        default:
          throw new TypeError('Unexpected data type (' + typeof target + ').')
      }

      return maps
    }
  }

  if (typeof define === 'function' && define.amd) {
    define([], factory)
  } else if (typeof module === 'object' && typeof module.exports === 'object') {
    module.exports = factory() //Node for browserfy
  } else {
    window.imageMapResize = factory()
  }

  if ('jQuery' in window) {
    window.jQuery.fn.imageMapResize = function $imageMapResizeF() {
      return this.filter('map')
        .each(scaleImageMap)
        .end()
    }
  }
})()
