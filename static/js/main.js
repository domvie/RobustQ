$(document).ready(function () {
    bsCustomFileInput.init();

    var form = document.querySelector('form');

    /*$(function () {
      $('[data-toggle="popover"]').popover({"trigger": "manual", "html": true})
    });*/

    if(sbml_errors === true) {
        errors = errors.split('* ');
        errors = errors.filter(function(el) {
            return el !== "";}
            );
        $('#id_sbml_file').popover({
                                    content: '<ul class="pl-3 pb-0"><li>' + errors.join('</li><li>') + '</li></ul>',
                                    html: true,
                                    placement: 'auto',
        }).popover('toggle');
    }
});
