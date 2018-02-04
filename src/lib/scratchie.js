// https://github.com/andreruffert/scratchie.js

(function() {

    'use strict';

    /**
     * Extend a given object with all the properties in passed-in object(s).
     *
     * @param  {Object} obj
     * @return {Object}
     */
    function extend(obj) {
        var i, l, prop, source;
        for (i=1, l=arguments.length; i<l; ++i) {
            source = arguments[i];
            for (prop in source) {
                if (hasOwnProperty.call(source, prop)) {
                    obj[prop] = source[prop];
                }
            }
        }
        return obj;
    }

    function appendStyle(styles) {
        var css = document.createElement('style');
        css.type = 'text/css';

        if (css.styleSheet) {
            css.styleSheet.cssText = styles;
        }
        else {
            css.appendChild(document.createTextNode(styles));
        }
        document.getElementsByTagName('head')[0].appendChild(css);
    }

    function distanceBetween(point1, point2) {
        return Math.sqrt(Math.pow(point2.x - point1.x, 2) + Math.pow(point2.y - point1.y, 2));
    }

    function angleBetween(point1, point2) {
        return Math.atan2( point2.x - point1.x, point2.y - point1.y );
    }

    // Module Configuration
    var instances = [],
        identifier = 0,
        moduleName = 'scratchie',
        defaults = {
            canvasClassName: 'scratchie-canvas',
            brush: 'data:image/png;base64,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',
            onRenderEnd: null,    // Callback fn
            onScratchMove: null   // Callback fn
        };

    /**
     * Module
     * @param {String} element  A selector e.g `.container`
     * @param {Object} options
     */
    function Module(element, options) {
        this.element            = element;
        this.options            = extend(defaults, options);
        this.id                 = 'js-' + moduleName + '-' + identifier++;
        this.enabled            = true;
        this.handleStart        = this.handleStart.bind(this);
        this.handelMove         = this.handleMove.bind(this);
        this.handleEnd          = this.handleEnd.bind(this);
        this.onRenderEnd        = this.options.onRenderEnd && this.options.onRenderEnd.bind(this);
        this.onScratchMove      = this.options.onScratchMove && this.options.onScratchMove.bind(this);

        this.brush              = new Image();
        this.brush.src          = this.options.brush;
        this.canvasWidth        = this.element.clientWidth;
        this.canvasHeight       = this.element.clientHeight;
        this.canvas             = document.createElement('canvas');
        this.canvas.className   = this.options.canvasClassName + ' js-' + moduleName + '-canvas';
        this.canvas.id          = this.id;
        this.ctx                = this.canvas.getContext('2d');
        this.element.className  = this.element.className + ' js-' + moduleName;
        this.element.id         = this.id;

        this.element.appendChild(this.canvas);
        this.addEvents();

        // Required styles
        if (identifier !== 1) { return; }
        appendStyle([
            '.js-' + moduleName + ' {',
                'position: relative;',
                '-webkit-user-select: none;',
                '-moz-user-select: none;',
                '-ms-user-select: none;',
                '-o-user-select: none;',
                'user-select: none;',
            '}',
            '.js-' + moduleName + '-canvas {',
                'position: absolute;',
                'top: 0;',
            '}'
        ].join('\n'));
    }

    Module.prototype.addEvents = function() {
        this.canvas.addEventListener('mousedown', this.handleStart, false);
        this.canvas.addEventListener('touchstart', this.handleStart, false);
        this.canvas.addEventListener('mouseup', this.handleEnd, false);
        this.canvas.addEventListener('touchend', this.handleEnd, false);
    };

    Module.prototype.render = function(value) {
        var type = (value.indexOf('.') > -1) ? 'image' : 'color'
        var _this = this;
        this.isDrawing = false;
        this.lastPoint = null;

        // The canvas size is defined by its container element.
        // Also triggers a redraw
        this.canvas.width = this.canvasWidth;
        this.canvas.height = this.canvasHeight;

        var fill = {
            color: function(color, cb) {
                _this.ctx.rect(0, 0, _this.canvasWidth, _this.canvasHeight);
                _this.ctx.fillStyle = color;
                _this.ctx.fill();
                cb();
            },
            image: function(src, cb) {
                var image = new Image();

                // workaround to prevent flicker of html behind canvas
                fill['color']('white', cb);

                image.onload = function() {
                    _this.ctx.drawImage(this, 0, 0);
                    cb();
                }

                // Fixes `onload()` for cached images
                image.src = src + '?' + new Date().getTime();
            }
        };

        fill[type](value, function() {
            if (_this.onRenderEnd && typeof _this.onRenderEnd === 'function') {
                _this.onRenderEnd();
            }
        });
    };

    Module.prototype.getFilledInPixels = function() {
        var imageData   = this.ctx.getImageData(0, 0, this.canvasWidth, this.canvasHeight),
            pixels      = imageData.data,
            numPixels   = imageData.width * imageData.height,
            count       = 0;

        // Iterate over the `pixels` data buffer
        for (var i = 0; i < numPixels; i++) {
            // rgba +3 is alpha
            if (parseInt(pixels[i*4+3]) === 0) {
                count++;
            }
        }

        return Math.floor((count / (this.canvasWidth * this.canvasHeight)) * 100);
    };

    // Returns mouse position relative to the `canvas` parent
    Module.prototype.getRelativePosition = function(e, canvas) {
        var offsetX = 0,
            offsetY = 0,
            pageX = 0,
            pageY = 0;

        if (canvas.offsetParent !== undefined) {
            while (canvas !== null) {
                offsetX += canvas.offsetLeft;
                offsetY += canvas.offsetTop;
                canvas = canvas.offsetParent
            }
        }


        pageX = e.pageX || e.touches[0].pageX;
        pageY = e.pageY || e.touches[0].pageY;


        return {
            x: pageX - offsetX,
            y: pageY - offsetY
        };
    };

    Module.prototype.handleStart = function(e) {
        if (!this.enabled) { return; }

        if (this.options.onStart)
          this.options.onStart();


        this.isDrawing = true;
        this.lastPoint = this.getRelativePosition(e, this.canvas);

        this.canvas.addEventListener('mousemove', this.handelMove, false);
        this.canvas.addEventListener('touchmove', this.handelMove, false);
    };

    Module.prototype.handleMove = function(e) {
        if (!this.isDrawing) { return; }

        // Prevent scrolling on touch devices
        e.preventDefault();

        var currentPoint = this.getRelativePosition(e, this.canvas),
            dist         = distanceBetween(this.lastPoint, currentPoint),
            angle        = angleBetween(this.lastPoint, currentPoint),
            x, y;

        for (var i = 0; i < dist; i++) {
            x = this.lastPoint.x + (Math.sin(angle) * i) - 25;
            y = this.lastPoint.y + (Math.cos(angle) * i) - 25;
            this.ctx.globalCompositeOperation = 'destination-out';
            this.ctx.drawImage(this.brush, x, y);
        }

        this.lastPoint = currentPoint;

        if (this.onScratchMove && typeof this.onScratchMove ==='function') {
            this.onScratchMove(this.getFilledInPixels());
        }
    };

    Module.prototype.handleEnd = function(e) {
        if (!this.enabled) { return; }

        this.isDrawing = false;

        this.canvas.removeEventListener('mousemove', this.handleMove, false);
        this.canvas.removeEventListener('touchmove', this.handleMove, false);
    };


    // Module wrapper
    function Scratchie(element, options) {
        // var elements = document.querySelectorAll(selector);

        // for (var i = 0, l = elements.length; i < l; i++) {
            // elements[i].
            var scratchie = new Module(element, options);
            // instances.push(elements[i]);

            // elements[i].
            scratchie.render(options.image);//elements[i].getAttribute('data-scratchie'));
        // }
    }

    // Returns all elements that are initialized with Scratchie
    // Scratchie.prototype.elements = instances;

    // Global expose
    // window.Scratchie = Scratchie;
    module.exports = Scratchie;
})();
