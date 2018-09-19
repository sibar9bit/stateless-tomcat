
package com.eternus.tomcat;

import javax.servlet.http.HttpSession;

import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.ModelAndView;

import java.util.Collection;

@RestController
public class HelloController {

    public static final String MY_USER_SESSION = "my-user-session";

    @RequestMapping("/")
    String index(HttpSession session) {
        if (session.getAttribute(MY_USER_SESSION) == null) {
            session.setAttribute(MY_USER_SESSION, new CleanupObject(session.getId()));
        }
        return session.getId();
    }

    @RequestMapping("/protected.do")
    String protectedPage(HttpSession session) {
        if (session.getAttribute(MY_USER_SESSION) == null) {
            session.setAttribute(MY_USER_SESSION, new CleanupObject(session.getId()));
        }
        return "In PROTECTED page, with sessionId: " + session.getId();
    }

    /**
     * Simulates the Saml login process of SamlLoginServlet in CCR/CCLF
     * @param model
     * @return
     */
    @RequestMapping("/login")
    ModelAndView login(ModelMap model, HttpSession session) {
        processResponse(session);
        return new ModelAndView("forward:/ssoLogin.jsp", model);
    }

    private void processResponse(HttpSession session) {
        String nameId = "TEST USER";
        String userRoles = "ROLE_USER";

        session.setAttribute("SSOuser", nameId);
        session.setAttribute("SSOpass", userRoles);

    }

}
