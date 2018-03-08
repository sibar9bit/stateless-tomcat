package com.eternus.tomcat;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import javax.servlet.http.HttpSessionBindingEvent;
import javax.servlet.http.HttpSessionBindingListener;
import java.io.Serializable;
import java.lang.invoke.MethodHandles;

/**
 *
 */
public class CleanupObject implements HttpSessionBindingListener, Serializable {

    private static long serialVersionUID = 23213349L;

    private static final Log logger = LogFactory.getLog(MethodHandles.lookup().lookupClass());

    @Override
    public void valueBound(HttpSessionBindingEvent event) {
        logger.info("Bound CleanupObject (created session)");
    }

    @Override
    public void valueUnbound(HttpSessionBindingEvent event) {
        logger.info("Unbound CleanupObject (session expired)");
    }
}
