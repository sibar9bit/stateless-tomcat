package com.eternus.login;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import javax.security.auth.Subject;
import javax.security.auth.callback.Callback;
import javax.security.auth.callback.CallbackHandler;
import javax.security.auth.callback.NameCallback;
import javax.security.auth.callback.PasswordCallback;
import javax.security.auth.login.LoginException;
import javax.security.auth.spi.LoginModule;
import java.security.Principal;
import java.util.*;

//import javax.security.auth.callback.TextInputCallback;

public class NewOraJAASLoginModule implements LoginModule {

	// callback handler settings
	static final int NUM_CALLBACKS = 2;
	static final int USERNAME_CALLBACK_INDEX = 0;
	static final int PASSWORD_CALLBACK_INDEX = 1;

	// initial state
	protected Subject _subject;
	protected CallbackHandler _callbackHandler;
	@SuppressWarnings("rawtypes")
	protected Map _sharedState;
	@SuppressWarnings("rawtypes")
	protected Map _options;

	// configuration options
	protected boolean _debug;

	// the authentication status
	protected boolean _succeeded;
	protected boolean _commitSucceeded;

	// username and password
	protected String _name;
	protected String _password;
	protected String _roles;

	protected ArrayList<NewOraJAASPrincipal> _authPrincipals;

	private static final Log log = LogFactory.getLog(NewOraJAASLoginModule.class);

	private String errorMessageCode;

	public NewOraJAASLoginModule() {
		log.info("NewOraJAASLoginModule - Default Constructor");
	}

	public boolean commit() throws LoginException {
		log.info("commit() start");
		if (_succeeded == false) {
			return false;
		} else {

			// add authenticated principals to the Subject
			if (getAuthPrincipals() != null) {
				for (int i = 0; i < getAuthPrincipals().size(); i++) {
					if (!_subject.getPrincipals().contains(
							getAuthPrincipals().get(i))) {
						_subject.getPrincipals()
								.add(getAuthPrincipals().get(i));
					}
				}
			}

			// in any case, clean out state
			cleanup();

			printSubject(_subject);

			_commitSucceeded = true;
			log.info("commit() succeeded");
			return true;
		}

	}

	@SuppressWarnings("rawtypes")
	public void initialize(Subject subject, CallbackHandler callbackHandler,
			Map sharedState, Map options) {
		log.info("Initialize()");
		this._subject = subject;
		this._callbackHandler = callbackHandler;
		this._sharedState = sharedState;
		this._options = options;

		printConfiguration(this);
	}

	public boolean login() throws LoginException {
		log.info("login()  start");
		long start = System.currentTimeMillis();
		Callback[] callbacks = new Callback[NUM_CALLBACKS];
		callbacks[USERNAME_CALLBACK_INDEX] = new NameCallback("username");
		callbacks[PASSWORD_CALLBACK_INDEX] = new PasswordCallback("password", false);

		try {
			_callbackHandler.handle(callbacks);

			_name = ((NameCallback) callbacks[USERNAME_CALLBACK_INDEX]).getName();
			
			char[] tmpPassword = ((PasswordCallback) callbacks[PASSWORD_CALLBACK_INDEX])
					.getPassword();
			if (tmpPassword == null) {
				// treat a NULL password as an empty password
				tmpPassword = new char[0];
			} else {
				_password = new String(tmpPassword);
			}
			
			// force the Logger trace context - Invoked by JASS (not by the
			// request based filter).
//			MDC.put("uid", _name);
//			MDC.put("sessId", StringUtils.right(request.getSession().getId(), 5));	
			_roles = _password;
			_password = "welcome1";
			log.info("user name = '"+_name+"'; '"+_password+"'; '"+_roles+"'");

			_authPrincipals = new ArrayList<NewOraJAASPrincipal>();

			log.info("login()  " + _name + " authenticated.");

			// Adding user name as principal to the subject
			NewOraJAASPrincipal p = new NewOraJAASPrincipal(_name);
			_authPrincipals.add(p);
			
			p = new NewOraJAASPrincipal(_password);
			_authPrincipals.add(p);

			// Adding roles to the subject
			Collection<String> roles = Arrays.asList(_roles.split(","));
			Iterator<String> rolesIt = roles.iterator();
			while (rolesIt.hasNext()) {
				String role = (String) rolesIt.next();
				_authPrincipals.add(new NewOraJAASPrincipal(role.replace(' ', '-')));
			}

			_succeeded = true;

		} catch (Exception e) {
			log.error("Login()  Unable to login: " + this.toString(), e);

			LoginException le = new LoginException();
			le.initCause(e.getCause());
			throw le;
		}
		log.info("Login()  Login successful taking "
				+ (System.currentTimeMillis() - start) + " millis. : "
				+ this.toString());
		return true;
	}
    
    /**
     * return a boolean if user is a member of this role.
     */
//    private boolean userHasRole(String role) {
//        
//        Iterator<String> rolesIter = ReferenceDataCache.getRoles().iterator();
//        while (rolesIter!=null && rolesIter.hasNext()) {
//            String thisRole = (String) rolesIter.next();
//            if (thisRole.equalsIgnoreCase(role)) {
//            	log.info("user has role: "+thisRole);
//            	return true;
//            }
//        }
//        
//        return false;
//    }

	public boolean abort() throws LoginException {
		log.info("abort() -  aborted authentication attempt.");

		if (_succeeded == false) {
			cleanup();
			return false;
		} else if (_succeeded == true && _commitSucceeded == false) {
			// login succeeded but overall authentication failed
			_succeeded = false;
			cleanup();
		} else {
			// overall authentication succeeded and commit succeeded,
			// but someone else's commit failed
			logout();
		}
		return true;
	}

	public boolean logout() {// throws LoginException {
		log.info("logout()  authentication failed. " + this.toString());
		_succeeded = false;
		_commitSucceeded = false;
		cleanupAll();
		return true;
	}

	// helper methods //

	protected void cleanup() {
		_name = null;
		_password = null;
	}

	protected void cleanupAll() {
		cleanup();

		if (getAuthPrincipals() != null) {
			for (int i = 0; i < getAuthPrincipals().size(); i++) {
				_subject.getPrincipals().remove(getAuthPrincipals().get(i));
			}
		}
	}

	protected static void printConfiguration(NewOraJAASLoginModule lm) {
		if (lm == null) {
			return;
		}
		log.info("NewOraJAASLoginModule configuration options:" + lm.toString());

	}

	protected static void printSet(Set<Principal> s) {
		try {
			Iterator<Principal> principalIterator = s.iterator();
			while (principalIterator.hasNext()) {
				Principal p = (Principal) principalIterator.next();
				log.info(p.toString());
			}
		} catch (Throwable t) {
		}
	}

	protected static void printSubject(Subject subject) {
		if (log.isDebugEnabled()) {

			if (subject == null) {
				return;
			}
			Set<Principal> s = subject.getPrincipals();
			if ((s != null) && (s.size() != 0)) {
				log
						.debug("printSubject()  NewOraJAASLoginModule added the following Principals:");
				printSet(s);
			}

			Set<Object> s1 = subject.getPublicCredentials();
			if ((s1 != null) && (s1.size() != 0)) {
				log
						.debug("printSubject()  NewOraJAASLoginModule added the following Public Credentials:");
				printSet(s);
			}

		}
	}

	protected ArrayList<NewOraJAASPrincipal> getAuthPrincipals() {
		return _authPrincipals;
	}

	public String toString() {
		StringBuffer sb = new StringBuffer(80);
		sb.append("(NewOraJAASLoginModule: - ");
		sb.append(" _name:[").append(this._name).append("]");
		sb.append(" _password:[").append(log.isDebugEnabled() ? this._password : "*****").append("]");
		sb.append(" _succeeded:[").append(this._succeeded).append("]");
//		sb.append(" _user:[").append(this._user).append("]");
		sb.append(")");
		return sb.toString();
	}

	public String getErrorMessageCode() {
		return errorMessageCode;
	}

	public void setErrorMessageCode(String errorMessageCode) {
		this.errorMessageCode = errorMessageCode;
	}
}
