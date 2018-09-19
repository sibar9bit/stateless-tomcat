<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
	// remove session attributes setup for auto-login, allowing manual login.   
    try {
        session.removeAttribute("autoUser");
        session.removeAttribute("autoPassword");
    }
    catch (java.lang.Throwable t) {}; // do not throw any exceptions, no harm done!
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <title>Access Denied Page</title>
	</head>

	<body>
		<div id="banner"><h1>Access Denied Page</h1></div>

		<div id="container">
			<div id="header">
			    <div id="title"><h2>Login Error</h2></div>
			</div>

		    <p>Sorry, you are not authorised to use this service.</p>
			<p><a href="login.jsp">Try logging in again?</a></p>
		</div>
    </body>
</html>
