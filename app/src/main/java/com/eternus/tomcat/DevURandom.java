package com.eternus.tomcat;

import java.security.SecureRandom;

/**
 *
 */
public class DevURandom {

    private static SecureRandom randomness = new SecureRandom();

    public static byte[] readRandom(int size) {
        byte[] result = new byte[size];
        randomness.nextBytes(result);
        return result;
    }
}
