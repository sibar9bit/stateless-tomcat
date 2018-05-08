
package com.eternus.tomcat;

import javax.servlet.http.HttpSession;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.beans.factory.annotation.Value;

@RestController
public class HelloController {

    public static final String MY_USER_SESSION = "my-user-session";

    @Value("session.size_bytes")
    private int sessionSizeBytes;

    @RequestMapping("/")
    String index(HttpSession session) {
        if (session.getAttribute(MY_USER_SESSION) == null) {
            session.setAttribute(MY_USER_SESSION, new CleanupObject(session.getId(), sessionSizeBytes));
        }
        return session.getId();
    }

}
