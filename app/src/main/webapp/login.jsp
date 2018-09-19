<html xmlns="http://www.w3.org/1999/xhtml">

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <title>Login Page</title>

    <jsp:useBean id="SSOuser" scope="session" class="java.lang.String" />
    <jsp:useBean id="SSOpass" scope="session" class="java.lang.String" />
    <script language="JavaScript" type="text/javascript">
        function auto_submit() {
            document.forms['j_login'].action='j_security_check';
            document.forms['j_login'].submit();
        }
    </script>
</head>
    <% if (SSOuser!=null && !SSOuser.equals("")) { %>
        <body onload="auto_submit()">
            <form name="j_login" action="" method="post">
                        <input type="hidden" name="autoUser" value="" />
                        <input type="hidden" name="autoPassword" value="" />
                        <input type="hidden" name="autoAccount" value="" />
                        <input type="hidden" name="j_username" value="<% if (SSOuser!=null && !SSOuser.equals("")) {%><%=SSOuser%><%}%>" />
                        <input type="hidden" name="j_password" value="<% if (SSOpass!=null && !SSOpass.equals("")) {%><%=SSOpass%><%}%>" />
            </form>

            <div id="container">
                <h1>Logging in...</h1>
            </div>
        </body>
    <% }else{ %>
        <body>
            <div id="container">
                <div id="header">
                    <div id="title"><h2>Session Expired</h2></div>
                </div>
                <br />
                <p>Your session has expired, you must close this window and log back to gain access.</p>
                <p><a href="#" onclick="javascript: window.close();">Close Window</a></p>
            </div>
        </body>
    <% } %>
</html>
