<!DOCTYPE html>
<html>
<head>
<title>Welcome to cool demo!</title>
<meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="0">
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
<script>
date = document.getElementById("date");
date.innerHTML = new Date();
</script>
</head>
<body>
<h1>Welcome - I am Server <mark>SERVER_MARKER!</mark></h1>
<p>This page is served by nginx running on backend server SERVER_MARKER.</p>

<p>The current date and time is:</p> <b><p id="date"></p></b>
<p><em>Thank you for watching this demo.</em></p>

<script>
date = document.getElementById("date");
date.innerHTML = new Date();
</script>
</body>
