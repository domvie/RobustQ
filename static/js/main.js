$(document).ready(function () {
    var qbtn = $('#getqueue');
    qbtn.click(() => {
        $.getJSON('/queue', null, (data) => {
            // qbtn.html('Approx ' + data.queue + ' queued tasks');

            qbtn.popover({ title: 'Queued tasks<span class="close-popover float-right text-secondary" id="cpq">' +
                    '<i class="fas fa-times"></i></span>',
                                            content: 'Approx ' + data.queue + ' queued tasks',
                                            html: true,
                                            placement: 'bottom'
                }).popover('toggle');

                    $(document).on('click','#cpq',function(){
                      qbtn.popover('hide');
                    });

        })
    })
});
