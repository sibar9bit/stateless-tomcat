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

    private static final long serialVersionUID = 23213349L;

    private static final Log logger = LogFactory.getLog(MethodHandles.lookup().lookupClass());

    private String id;

    CleanupObject(String id) {
        this.id = id;
    }

    @Override
    public void valueBound(HttpSessionBindingEvent event) {
        logger.info(String.format("Bound CleanupObject %s (created session)", event.getValue().toString()));
    }

    @Override
    public void valueUnbound(HttpSessionBindingEvent event) {
        logger.info(String.format("Unbound CleanupObject %s (session expired)", event.getValue().toString()));
    }

    @Override
    public String toString() {
        return this.id;
    }
}
