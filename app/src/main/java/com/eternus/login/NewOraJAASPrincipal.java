package com.eternus.login;

import java.security.Principal;

public class NewOraJAASPrincipal implements Principal {

private String name;
	
	public NewOraJAASPrincipal(String userName) {
		this.name = userName;
	}


	public String getName() {
		return this.name;
	}
	
	public boolean equals(Principal principal) {
		if (principal == null)
		    return false;

        if (this == principal)
            return true;
 
        if (!(principal instanceof NewOraJAASPrincipal))
            return false;
        
	    NewOraJAASPrincipal _prinicpal = (NewOraJAASPrincipal)principal;
		if (this.getName().equals(_prinicpal.getName()))
		    return true;
		
		return false;

	}

	public String toString() {
		StringBuffer sb = new StringBuffer();
		sb.append("Principal Name: "+ name);

		return sb.toString();
	}
}
