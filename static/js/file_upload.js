// function submit_this_form() {
//     var eventSource = new EventSource("/uploadstream/test");
//     eventSource.onmessage = function(event) {
//         console.log(event.data)
//     };
//
//     $('#jobform').submit(function(e) {
//         $('#jobsubmitbtn').hide();
//         $('#pageloader').show();
//
//     });
// }

// Generate 32 char random uuid
function gen_uuid() {
    var uuid = ""
    for (var i=0; i < 32; i++) {
        uuid += Math.floor(Math.random() * 16).toString(16);
    }
    return uuid
}

// Add upload progress for multipart forms.
$(function() {
    $('#jobform').submit(function(){
        // Prevent multiple submits
        if ($.data(this, 'submitted')) return false;

        var freq = 2000; // freqency of update in ms
        var uuid = gen_uuid(); // id for this upload so we can fetch progress info.
        var progress_url = '/upload_progress/'; // ajax view serving progress info
        var progressbar = $('#progressbar');
        var progress_container = $('#progressbar_container');

        $('#jobsubmitbtn').hide();
        $('#pageloader').show();
        progress_container.show();

        // Append X-Progress-ID uuid form action
        this.action += (this.action.indexOf('?') === -1 ? '?' : '&') + 'X-Progress-ID=' + uuid;


        // Update progress bar
        function update_progress_info() {
            function reqListener () {
              var data = JSON.parse(this.responseText);
              if (data === null) {
                  progress_req.abort();
                  return
              }
              console.log(data);
              progressbar.html(data.status+'..');
              if (data.status === 'Uploading') {
                  var progress = parseInt(data.received) / parseInt(data.size);
                  progressbar.width(progress*50+'%');
              }
              else if (data.status === 'Validating') {
                  var progress = parseInt(data.done) / parseInt(data.total);
                  progressbar.width((50+progress*50)+'%');
              }
            }

            // $.getJSON(progress_url, {'X-Progress-ID': uuid}, function(data, status){
            //     if (data) {
            //         console.log(data);
            //         var progress = parseInt(data.uploaded) / parseInt(data.length);
            //         var width = $progress.find('.progress-container').width();
            //         var progress_width = width * progress;
            //         $progress.find('.progress-bar').width(progress_width);
            //         $progress.find('.progress-info').text('uploading ' + parseInt(progress*100) + '%');
            //     }
            //     window.setTimeout(update_progress_info, freq);
            // });
            var progress_req = new XMLHttpRequest();
            progress_req.addEventListener("load", reqListener);
            progress_req.upload.addEventListener("load", reqListener);
            progress_req.onerror = () =>  {
                console.log('There was an error: ');
                progress_req.abort();
            };

            progress_req.open("GET", progress_url+uuid);
            progress_req.send();
            window.setTimeout(update_progress_info, freq);
        }
        window.setTimeout(update_progress_info, freq);

        $.data(this, 'submitted', true); // mark form as submitted.
    });
});

//     (function($){
//         $(function(){
//     $(document).ready(function() {
//         $( "#form_id" ).submit(function( event ) {
//           event.preventDefault();
//
//           var post_data = new FormData($("form")[0]);
//
//           $.ajax({
//               xhr: function() {
//                 var xhr = new window.XMLHttpRequest();
//                 var new_div = document.createElement('div');
//
//                 new_div.innerHTML = '<progress id="progressBar" value="0" max="100" style="width:300px;"></progress><h3 id="status"></h3><p id="loaded_n_total"></p>';
//                 document.getElementsByClassName('submit-row')[0].appendChild(new_div)
//
//                 xhr.upload.addEventListener("progress", progressHandler, false);
//                 xhr.addEventListener("load", completeHandler, false);
//                 xhr.addEventListener("error", errorHandler, false);
//                 xhr.addEventListener("abort", abortHandler, false);
//
//                 return xhr;
//               },
//                 url: window.location.href,// to allow add and edit
//                 type: "POST",
//                 data: post_data,
//                 processData: false,
//                 contentType: false,
//                 success: function(result) {
//                     window.location.replace("/admin/yourapp/yoursupermodel/");
//               }
//             });
//         });
//     });
// });
// })(django.jQuery);
//
// function _(el) {
//   return document.getElementById(el);
// }
//
// function progressHandler(event) {
//   _("loaded_n_total").innerHTML = "Uploaded " + event.loaded + " bytes of " + event.total;
//   var percent = (event.loaded / event.total) * 100;
//   _("progressBar").value = Math.round(percent);
//   _("status").innerHTML = Math.round(percent) + "% uploaded... please wait";
// }
//
// function completeHandler(event) {
//   _("status").innerHTML = event.target.responseText;
//   _("progressBar").value = 0; //wil clear progress bar after successful upload
// }
//
// function errorHandler(event) {
//   _("status").innerHTML = "Upload Failed";
//
// }
//
// function abortHandler(event) {
//   _("status").innerHTML = "Upload Aborted";
// }