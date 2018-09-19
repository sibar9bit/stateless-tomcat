<%
  response.setHeader("Expires", "Sat, 6 May 1995 12:00:00 GMT"); // Set to expire far in the past.
  response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate"); // Set standard HTTP/1.1 no-cache headers.
  response.addHeader("Cache-Control", "post-check=0, pre-check=0"); // Set IE extended HTTP/1.1 no-cache headers (use addHeader).
  response.setHeader("Pragma", "no-cache"); // Set standard HTTP/1.0 no-cache header.
%>
   
<html xmlns="http://www.w3.org/1999/xhtml">

    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <title>SSOLogin Page</title>

        <script language="JavaScript" type="text/javascript">
            function submit() {
                document.forms['home'].submit();
            }
        </script>
    </head>

    <body onload="submit()">

		<form name="home" action="protected.do" method="post"></form>

		<div id="container">
		    <h1>Logging in...</h1>	    
	    </div>
    </body>
</html>
