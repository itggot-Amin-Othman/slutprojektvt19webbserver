$(document).ready(function () {
    // get MathJax output object
    var mjDisplayBox, mjOutBox;
    MathJax.Hub.Queue(function () {
        mjDisplayBox = MathJax.Hub.getAllJax('math-display')[0];
        mjOutBox = MathJax.Hub.getAllJax('math-output')[0];
    });

    // "live update" MathJax whenever a key is pressed
    $('#math-input').on('keyup', function (evt) {
        var math = $(this).val();
        $(this).css('color', 'black');
        if (math.length > 0) {
            try {
                var tree = MathLex.parse(math),
                    latex = MathLex.render(tree, 'latex');
                MathJax.Hub.Queue(['Text', mjDisplayBox, latex]);
            } catch (err) {
                $(this).css('color', 'red');
            }
        } else {
            // clear display and output boxes if input is empty
            MathJax.Hub.Queue(['Text', mjDisplayBox, '']);
            MathJax.Hub.Queue(['Text', mjOutBox, '']);
        }
    });

    // send output to sage server
    $('#send-math').on('click', function (evt) {
        var math = $('#math-input').val();
        if (math.length > 0) {
            try {
                var tree = MathLex.parse(math),
                    sageCode = MathLex.render(tree, 'sage');
                $.post('http://aleph.sagemath.org/service?callback=?',
                        { code: 'print latex('+sageCode+')' }, function (data) {
                    // HACK: Firefox does not convert data to JSON
                    if (typeof(data) === 'string') { 
                        data = $.parseJSON(data); 
                    }
                    // AJAX success callback
                    if (data.success) {
                        MathJax.Hub.Queue(['Text', mjOutBox, data.stdout]);
                    } else {
                        MathJax.Hub.Queue(['Text', mjOutBox, '\\text{Sage could not understand that input}']);
                    }
                });
            } catch (err) {
                MathJax.Hub.Queue(['Text', mjOutBox, '\\text{Check your syntax and try again}']);
            }
        }
    });
});