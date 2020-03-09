$(document).ready(function () {
    // var job_id = document.getElementById("job_id");

    cancelJob = (id) => {
        fetch('/jobs/cancel/'+id, { headers: { "Content-Type": "application/json; charset=utf-8" }})
            .then(response => {
                setTimeout(function(){}, 2000);
                location.reload();
            }).catch(err => {
                console.log('error');
            });
    }
});